<?php

namespace Releaser;

/**
 * Class Releaser
 *
 * todo: options: master cut, patch master, patch patch
 *
 * todo:
 * if any dependency is released,
 * then all dependencies depending on that also must be released,
 * and then dependencies depending on those as well
 *
 * todo:
 * if there are separate main repo 2 dependencies
 * each also depending on each other, and only 1 requiring a release -
 * validate the other one gets released too
 *
 * todo: validate it works if dependency has not current release
 * @package Releaser
 */
class Releaser
{
    /**
     * get token https://github.com/settings/tokens/new with "repo" access
     */
    const GITHUB_TOKEN = '';

    /**
     * release repos for htis owner
     */
    const GITHUB_OWNER = 'discovery-fusion';

    /**
     * Github API root
     */
    const GITHUB_ROOT = 'https://api.github.com/';

    private $mainRepo;
    private $repos;
    private $toBeReleased;
    private $currentRepo;

    /**
     * Releaser constructor.
     * @param string $main
     * @param array $dependencies
     */
    public function __construct($main, array $dependencies)
    {
        $this->mainRepo = $main;
        $dependencies[] = $main;
        $this->repos = array_combine($dependencies, $dependencies);
        $this->verifyAllStatuses();
        $this->release();
    }

    /**
     *
     */
    private function verifyAllStatuses()
    {
        foreach ($this->repos as $dep) {
            $this->verifyStatus($dep);
        }
    }

    /**
     * @param $repo
     */
    private function verifyStatus($repo)
    {
        $this->currentRepo = $repo;
        $releases = $this->curlGetReleases();
        $this->getLatestVersions($releases);
        $this->branchNeedsANewRelease('master', $this->repos[$this->currentRepo]['current_master']);
    }

    /**
     *
     */
    private function release()
    {
        $count = count($this->toBeReleased);
        $this->msg("\n");
        if ($count === 0) {
            $this->err("No repositories require a release! :)");
        }

        $this->msg("New $this->mainRepo {$this->repos[$this->mainRepo]['next_master']} to be released");
        $this->msg("depending on $count new:");
        foreach ($this->toBeReleased as $repo) {
            $this->msg($this->repos[$repo]['current_master'] . ' ' . $repo);
        }

        $this->promptUserWhetherToProceed();

        foreach ($this->toBeReleased as $repo) {
            $this->currentRepo = $repo;
            $this->createDotXBranch();
        }

        //Release main repo


    }

    private function createDotXBranch()
    {
        $ref = $this->getSourceRefHead();
        if (isset($ref->object->sha)) {
            $sha = $ref->object->sha;
        } else {
            var_dump($ref);
            $this->err("Failed to obtain stable branch last commit sha hash");
        }

        $this->createDotXRef($sha);
        $this->releaseDotXBranch();

    }

    /**
     *
     */
    private function promptUserWhetherToProceed()
    {
        $this->msg("\n");
        $this->msg("Are you sure you want to release these packages?");
        $this->msg("Type YES(y) to continue, NO(n) to abort...");
        $handle = fopen("php://stdin", "r");
        $line = fgets($handle);
        $userVal = trim($line);
        if (!in_array($userVal, ['y', 'Y', 'yes', 'YES'])) {
            $this->err("\nAborting!");
        }
        fclose($handle);
        $this->msg("\nContinuing with release, press  Ctrl+C  to abort manually");
    }

    /**
     * @param $releases
     */
    private function getLatestVersions($releases)
    {
        $tagsThreeLevels = [];
        foreach ($releases as $release) {
            $explodedTag = explode('.', $release->tag_name);

            $first = (int)$explodedTag[0];
            $second = (int)$explodedTag[1];
            $third = (int)$explodedTag[2];
            if (!array_key_exists($first, $tagsThreeLevels)) {
                $tagsThreeLevels[$first] = [];
            }
            if (!array_key_exists($second, $tagsThreeLevels[$first])) {
                $tagsThreeLevels[$first][$second] = [];
            }
            if (!array_key_exists($third, $tagsThreeLevels[$first][$second])) {
                $tagsThreeLevels[$first][$second][] = $third;
            }
        }
        $masterVMaxLevel1 = max(array_keys($tagsThreeLevels));
        $masterVMaxLevel2 = max(array_keys($tagsThreeLevels[$masterVMaxLevel1]));
        $masterVMaxLevel3 = max($tagsThreeLevels[$masterVMaxLevel1][$masterVMaxLevel2]);

        $patchVMaxLevel3 = min($tagsThreeLevels[$masterVMaxLevel1][$masterVMaxLevel2]);

        $this->repos[$this->currentRepo] = [
            'current_master' => "$masterVMaxLevel1.$masterVMaxLevel2.$masterVMaxLevel3",
            'next_master'    => "$masterVMaxLevel1." . ($masterVMaxLevel2 + 1) . ".$masterVMaxLevel3",
            'current_patch'  => ($patchVMaxLevel3 > 0 ? "$masterVMaxLevel1.$masterVMaxLevel2.$patchVMaxLevel3" : null),
            'next_branch'    => "$masterVMaxLevel1." . ($masterVMaxLevel2 + 1) . ".x",
        ];

        $this->msg(
            "$this->currentRepo latest master release {$this->repos[$this->currentRepo]['current_master']}, "
            . ($this->repos[$this->currentRepo]['current_patch'] ? 'patched with '
                . $this->repos[$this->currentRepo]['current_patch'] : 'not patched')
        );
    }

    /**
     * @param $branch
     * @param $releaseVersion
     */
    private function branchNeedsANewRelease($branch, $releaseVersion)
    {
        $comparison = $this->curlMasterReleaseAndMasterComparison($branch, $releaseVersion);
        $this->msg(
            "$this->currentRepo $branch branch is {$comparison->status} comparing to master release. Ahead by {$comparison->ahead_by}, behind by {$comparison->behind_by} commits"
        );

        if (($comparison->ahead_by > 0)) {
            $this->toBeReleased[] = $this->currentRepo;
            $this->msg("> $this->currentRepo needs new release ");
        }
    }

    /**
     * @return mixed
     */
    private function createDotXRef($sha)
    {
        $path = 'repos/' . static::GITHUB_OWNER . '/' . $this->currentRepo . '/git/refs';
        $newRef = $this->repos[$this->currentRepo]['next_branch'];
        $postData = [
            'ref' => 'refs/heads/' . $newRef,
            'sha' => $sha
        ];
        $result = $this->executeCurlRequest($path, $postData);

        if (isset($result->ref) && $result->ref === $postData['ref']) {
            $this->msg("Branch $newRef created for $this->currentRepo");

            return true;
        }

        var_dump($result);
        $this->err("Failed to create new ref. Aborting");
    }

    private function releaseDotXBranch()
    {
        $path = 'repos/' . static::GITHUB_OWNER . '/' . $this->currentRepo . '/releases';
        $newTag = $this->repos[$this->currentRepo]['next_master'];
        $releaseData = [
            'tag_name'         => $newTag,
            'target_commitish' => $this->repos[$this->currentRepo]['next_branch'],
            'name'             => $newTag,
            'body'             => 'Created by robots ' . date("D M d, Y G:i a"),
            'draft'            => false,
            'prerelease'       => false
        ];

        $result = $this->executeCurlRequest($path, $releaseData);
        if (isset($result->tag_name) && $result->tag_name === $releaseData['tag_name']) {
            $this->msg("Released $newTag $this->currentRepo");

            return true;
        }

        var_dump($result);
        $this->err("Failed to release $this->currentRepo. Aborting");
    }

    /**
     * @param $branch
     * @param $releaseVersion
     * @return mixed
     */
    private function curlMasterReleaseAndMasterComparison($branch, $releaseVersion)
    {
        $path = 'repos/'
            . static::GITHUB_OWNER
            . '/'
            . $this->currentRepo
            . '/compare/'
            . $releaseVersion
            . '...'
            . $branch;

        return $this->executeCurlRequest($path);
    }

    /**
     * @return mixed
     */
    private function curlGetReleases()
    {
        $path = 'repos/' . static::GITHUB_OWNER . '/' . $this->currentRepo . '/releases';
        $releases = $this->executeCurlRequest($path);

        return $releases;
    }

    /**
     * @return mixed
     */
    private function getSourceRefHead()
    {
        $path = 'repos/' . static::GITHUB_OWNER . '/' . $this->currentRepo . '/git/refs/heads/master';
        $ref = $this->executeCurlRequest($path);

        return $ref;
    }


    /**
     * @param $urlPath
     * @return mixed
     */
    private function executeCurlRequest($urlPath, $requestData = [])
    {
        $url = static::GITHUB_ROOT . $urlPath . '?access_token=' . static::GITHUB_TOKEN;
        //var_dump($url);
        $ch = curl_init();
        $options = [
            CURLOPT_URL            => $url,
            CURLOPT_RETURNTRANSFER => 1,
            CURLOPT_USERAGENT      => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.13) Gecko/20080311 Firefox/2.0.0.13'
        ];
        if (!empty($requestData)) {
            $options[CURLOPT_POSTFIELDS] = json_encode($requestData);
        }
        curl_setopt_array($ch, $options);

        $result = @json_decode(curl_exec($ch));

        if (isset($result->message)) {
            $t = (static::GITHUB_TOKEN == '') ? ' const GITHUB_TOKEN is empty!' : '';
            $this->err("{$result->message}. $t ABORTING");
        }

        return $result;
    }

    /**
     * @param $message
     */
    private function msg($message)
    {
        echo "$message \n";
    }

    /**
     * @param $message
     */
    private function err($message)
    {
        echo "$message \n";
        exit;
    }
}

/**
 * All dependencies of the main repo
 * and all the sub-dependencies of hose dependencies that needs a release
 * starting with most common libraries with no releasable dependencies on top
 */
$userApiDependencies = [
//    'fusion-build-utilities',
//    'fusion-commons-core',
    'fusion-lib-wireless-factory',
//    'fusion-lib-vouchers',
//    'fusion-session-management',
//    'fusion-authentication',
//    'fusion-authorisation',
//    'fusion-account-management',
//    'fusion-subscription',
//    'fusion-lib-payment',
];

new Releaser('fusion-api-user', $userApiDependencies);

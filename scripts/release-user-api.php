<?php

namespace Releaser;

class Releaser
{
    # generate your Github Token @ https://github.com/settings/tokens/new  with "repo" access
    const GITHUB_TOKEN = '2e34287ca20fe380aa8fc54b6eea270140a48e84';
    const GITHUB_OWNER = 'discovery-fusion';
    const GITHUB_ROOT  = 'https://api.github.com/';

    private $versionsToBeReleased = [];
    private $currentRepo;
    private $currentMasterReleaseVersion;
    private $currentPatchReleaseVersion;
    private $nextMasterReleaseVersion;
    private $nextPatchReleaseVersion;
    // todo:
    // combinate dependency tree to f.eks. release new User API if deps needs a release
    // release with changed dep versions

    // options:
    // master cut
    // patch master
    // patch patch

    public function __construct()
    {
        // common repos
        $this->verifyStatus('fusion-build-utilities');
        $this->verifyStatus('fusion-commons-core');

        // packages
        $this->verifyStatus('fusion-lib-wireless-factory');
//        $this->verifyStatus('fusion-lib-vouchers');
//        $this->verifyStatus('fusion-session-management');
//        $this->verifyStatus('fusion-authentication');
//        $this->verifyStatus('fusion-authorisation');
//        $this->verifyStatus('fusion-account-management');
//        $this->verifyStatus('fusion-subscription');
//        $this->verifyStatus('fusion-lib-payment');
//        $this->verifyStatus('fusion-lib-payment');

        // main user API
        $this->verifyStatus('fusion-api-user');

        $this->release();
    }

    private function release()
    {
        $count = count($this->versionsToBeReleased);
        $this->msg("\n");
        if ($count === 0) {
            $this->msg("No repositories require a release! :)");
            die;
        }

        $this->msg("$count repositories to be released:");
        foreach ($this->versionsToBeReleased as $repo => $version) {
            $this->msg("$version $repo");
        }

        $this->promptUserWhetherToProceed();




    }

    private function promptUserWhetherToProceed()
    {
        $this->msg("\n");
        $this->msg("Are you sure you want to release these packages?");
        $this->msg("Type YES(y) to continue, NO(n) to abort...");
        $handle = fopen ("php://stdin","r");
        $line = fgets($handle);
        $userVal = trim($line);
        if(!in_array($userVal, ['y', 'Y', 'yes', 'YES'])){
            $this->msg("\nAborting!");
            exit;
        }
        fclose($handle);
        $this->msg("\nContinuing with release, press  Ctrl+C  to abort manually");
    }

    private function verifyStatus($repo)
    {
        $this->currentRepo = $repo;
        $releases          = $this->curlGetReleases();
        $this->getLatestVersions($releases);
        $this->branchNeedsANewRelease('master', $this->currentMasterReleaseVersion);
    }

    private function getLatestVersions($releases)
    {
        $tagsThreeLevels = [];
        foreach ($releases as $release) {
            $explodedTag = explode('.', $release->tag_name);

            $first  = (int) $explodedTag[0];
            $second = (int) $explodedTag[1];
            $third  = (int) $explodedTag[2];
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
        $this->currentMasterReleaseVersion = "$masterVMaxLevel1.$masterVMaxLevel2.$masterVMaxLevel3";
        $this->nextMasterReleaseVersion = "$masterVMaxLevel1." . ($masterVMaxLevel2 + 1) . ".$masterVMaxLevel3";

        $patchVMaxLevel3 = min($tagsThreeLevels[$masterVMaxLevel1][$masterVMaxLevel2]);
        $this->currentPatchReleaseVersion = ($patchVMaxLevel3 > 0) ? "$masterVMaxLevel1.$masterVMaxLevel2.$patchVMaxLevel3" : null;
        $this->nextPatchReleaseVersion = ($this->currentPatchReleaseVersion) ? "$masterVMaxLevel1.$masterVMaxLevel2." . ($patchVMaxLevel3 + 1) : null;

        $this->msg(
            "{$this->currentRepo} latest master release $this->currentMasterReleaseVersion, "
            . ($this->currentPatchReleaseVersion ? 'patched with ' . $this->currentPatchReleaseVersion  : 'not patched')
        );
    }

    private function branchNeedsANewRelease($branch, $releaseVersion)
    {
        $comparison = $this->curlMasterReleaseAndMasterComparison($branch, $releaseVersion);
        $this->msg(
            "$this->currentRepo $branch branch is {$comparison->status} comparing to master release. Ahead by {$comparison->ahead_by}, behind by {$comparison->behind_by} commits"
        );

        $needsRelease = ($comparison->ahead_by > 0);
        if ($needsRelease) {
            $this->versionsToBeReleased[$this->currentRepo] = $this->nextMasterReleaseVersion;
            $this->msg("> $this->currentRepo needs new release ");
        }
    }

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

        return @json_decode($this->executeCurlRequest($path));
    }

    private function curlGetReleases()
    {
        $path = 'repos/' . static::GITHUB_OWNER . '/' . $this->currentRepo . '/releases';

        $releases = @json_decode($this->executeCurlRequest($path));
        if (isset($releases->message)) {
            $t = (static::GITHUB_TOKEN == '') ? ' const GITHUB_TOKEN is empty!' : '';
            $this->msg("{$releases->message}. $t ABORTING");
            exit;
        }

        return $releases;
    }

    private function executeCurlRequest($urlPath)
    {
        $url = static::GITHUB_ROOT . $urlPath . '?access_token=' . static::GITHUB_TOKEN;
        $ch  = curl_init();
        curl_setopt_array(
            $ch,
            [
                CURLOPT_URL            => $url,
                CURLOPT_RETURNTRANSFER => 1,
                CURLOPT_USERAGENT      => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.13) Gecko/20080311 Firefox/2.0.0.13'
            ]
        );

        return curl_exec($ch);
    }

    private function msg($message)
    {
        echo "$message \n";
    }
}

new Releaser();

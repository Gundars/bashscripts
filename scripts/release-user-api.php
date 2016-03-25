<?php

class Releaser
{
    # generate your Github Token @ https://github.com/settings/tokens/new  with "repo" access
    const GITHUB_TOKEN = '';
    const GITHUB_OWNER = 'discovery-fusion';
    const GITHUB_ROOT  = 'https://api.github.com/';

    private $repoLatestMasterVersions;
    private $currentRepo;

    // todo:
    // options:
    // master cut
    // patch master
    // patch patch

    public function __construct()
    {
        // common repos
        $this->releaseIfNewCommits('fusion-build-utilities');
        $this->releaseIfNewCommits('fusion-commons-core');

        // packages
        $this->releaseIfNewCommits('fusion-lib-wireless-factory');
        $this->releaseIfNewCommits('fusion-lib-vouchers');
        $this->releaseIfNewCommits('fusion-session-management');
        $this->releaseIfNewCommits('fusion-authentication');
        $this->releaseIfNewCommits('fusion-authorisation');
        $this->releaseIfNewCommits('fusion-account-management');
        $this->releaseIfNewCommits('fusion-subscription');
        $this->releaseIfNewCommits('fusion-lib-payment');
        $this->releaseIfNewCommits('fusion-lib-payment');

        // main user API
        $this->releaseIfNewCommits('fusion-api-user');
    }

    private function releaseIfNewCommits($repo)
    {
        $this->currentRepo = $repo;
        $releases          = $this->curlGetReleases();
        list($lastMasterV, $lastPatchV) = $this->getLatestVersions($releases);
        $this->log(
            "{$this->currentRepo} latest master release $lastMasterV, currently patched: "
            . ($lastPatchV ? $lastPatchV : 'no')
        );
        $needsRelease = $this->branchNeedsANewRelease('master', $lastMasterV);

        if ($needsRelease) {
            $this->log("$this->currentRepo needs new master release!");

            $this->repoLatestMasterVersions[$this->currentRepo] = 'some newly created repo master cut version';
        } else {
            $this->repoLatestMasterVersions[$this->currentRepo] = $lastMasterV;
        }
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
        $masterVMax       = "$masterVMaxLevel1.$masterVMaxLevel2.$masterVMaxLevel3";

        $patchVMaxLevel3 = min($tagsThreeLevels[$masterVMaxLevel1][$masterVMaxLevel2]);
        $patchVMax       = ($patchVMaxLevel3 > 0) ? "$masterVMaxLevel1.$masterVMaxLevel2.$patchVMaxLevel3" : null;

        return [$masterVMax, $patchVMax];
    }

    private function branchNeedsANewRelease($branch, $releaseVersion)
    {
        $comparison = $this->curlMasterReleaseAndMasterComparison($branch, $releaseVersion);
        $this->log(
            "$this->currentRepo master branch is {$comparison->status} comparing to master release. Ahead by {$comparison->ahead_by}, behind by {$comparison->behind_by} commits"
        );

        return ($comparison->ahead_by > 0);
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

        return @json_decode($this->executeCurlRequest($path));
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

    private function log($message)
    {
        echo "$message \n";
    }
}

new Releaser();

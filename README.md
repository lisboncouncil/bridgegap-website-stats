# BridgeGap Matomo Analytics: Handover Archive

This repository holds a CSV and JSON snapshot of the analytics history captured by Matomo for the BridgeGap project website, [corruptiondata.eu](https://corruptiondata.eu/), prepared for handover to the partner taking over operational responsibility for the site.

The Matomo instance used to track the site will be decommissioned and replaced by GA4 under the new arrangement. This archive is therefore the **historical reference** for the period during which Matomo was the source of truth: it is meant to be read alongside any future GA4 data, not merged with it.

## About BridgeGap

BridgeGap is a Horizon Europe research project (Grant Agreement 101132483), addressing corruption as a policy problem and producing data, tools and analyses on cross-border anti-corruption. The website [corruptiondata.eu](https://corruptiondata.eu/) is the project's public-facing communication and dissemination platform, and is the site whose traffic is captured in this archive.

## Tracked site and time coverage

| Item | Value |
|---|---|
| Tracked site | `https://corruptiondata.eu/` |
| Matomo instance | `https://lisboncouncilresearch.com/matomo/` |
| Site ID in Matomo | `7` |
| Tracking start date | 21 February 2024 |
| Export end date | see the timestamp in the export folder name (`matomo_export_YYYYMMDD_HHMMSS`) |
| Date range used in queries | `2024-02-21` to the export date |

All reports cover the full lifetime of the tracking unless the file name explicitly indicates otherwise (for example `_daily`, `_weekly`, `_monthly`).

## Repository contents

```
.
├── README.md              ← this document
├── matomo_export.sh       ← script that regenerates a fresh export
├── matomo_urls.txt        ← reference list of every API URL used by the script
└── matomo_export_<timestamp>/
    ├── MANIFEST.txt
    ├── SHA256SUMS
    ├── 01_overview_*.csv
    ├── 10_*.csv ... 16_*.csv      (acquisition)
    ├── 20_*.csv ... 27_*.csv      (behaviour and pages)
    ├── 30_*.csv ... 32_*.csv      (events)
    ├── 40_*.csv ... 42_*.csv      (geography)
    ├── 50_*.csv ... 55_*.csv      (device and software)
    ├── 60_*.csv ... 64_*.csv      (engagement)
    ├── 70_*.csv ... 73_*.csv      (goals)
    └── config_*.json              (Matomo configuration dumps)
```

The numeric prefix groups files by topic. Within each topic the files are independent: any of them can be opened in a spreadsheet tool without needing the others.

### 01–03 Overview time series

`VisitsSummary` aggregated at three granularities. These are the headline metrics (visits, unique visitors, page views, average time on site, bounce rate, actions per visit) over time. Use the daily file for fine-grained trend analysis and the monthly file for executive summaries.

### 10–16 Acquisition

How visitors reached the site, broken down by channel, referring website, search engine, keyword (mostly anonymised by search providers), social network, and UTM-tagged campaign. The `10_channels.csv` file is the most useful starting point for a high-level view.

### 20–27 Behaviour and pages

Top URLs and titles, entry and exit pages, outbound links, downloaded files, and on-site search keywords. URLs are flattened, meaning the file shows the full path of each page rather than a hierarchical tree by directory. A site search file with no rows simply means on-site search tracking was not configured: this is documented evidence that the feature was not in use.

### 30–32 Events

Custom event tracking, broken down by category, action, and name. Empty files indicate that no custom events were tracked during the period.

### 40–42 Geography

Visits by country, region, and city.

### 50–55 Device and software

Device type (desktop/mobile/tablet), brand, model, operating system family, browser, and screen resolution.

### 60–64 Engagement

Distributions describing how engaged the audience was: how often visitors return, how long they stay, how many pages they view, and how many visits precede a re-visit.

### 70–73 Goals

Conversion data: aggregate goal performance, monthly trend, and the standard time-to-conversion and visits-to-conversion distributions. The definitions of the goals themselves are in `config_goals.json` (see below).

### Integrity files

* `MANIFEST.txt`: human-readable summary of the export (site, range, export timestamp, file count, total size, full SHA-256 checksum table).
* `SHA256SUMS`: machine-readable checksum file in the standard `sha256sum` format.

To verify that no file in the bundle has been altered or corrupted in transit, run the following from inside the export folder:

```bash
sha256sum -c SHA256SUMS
```

Every line should report `OK`. Any `FAILED` entry means that file no longer matches the checksum recorded at export time.

## Important caveats for the recipient

**Matomo and GA4 are not directly comparable.** Matomo uses a hit-based model with the classic web analytics vocabulary (visits, unique visitors, bounce rate). GA4 uses an event-based model with sessions, users, and engagement rate. Treat this archive as a historical baseline, not as a dataset to align with future GA4 figures. Year-on-year comparisons that straddle the platform switch will be misleading unless adjusted carefully.

**Sampling and consent.** Matomo applies no sampling: the figures here are exact for what was tracked. They reflect only those visits that passed the cookie consent or tracking opt-in logic in place at the time. If the consent banner blocked a portion of traffic, those visits are not in this dataset and never were.

**Filter limits.** A handful of long-tail tables (page URLs, referring websites, keywords) are capped at a high but finite number of rows (1,000 to 2,000). For practical reporting purposes this captures essentially all meaningful traffic. If absolute completeness is required for a specific report, it can be re-exported with `filter_limit=-1`.

**Empty tables.** A CSV with only the header row is not a bug. It means Matomo had no data to report for that dimension during the period (typical examples: site search, custom events, certain campaigns). The empty file is itself useful evidence in a handover: it confirms that the feature was not in use.

## Re-running the export

The export script `matomo_export.sh` is included so that a fresh archive can be regenerated at any time before the Matomo instance is decommissioned (for example, to capture data for the days between this snapshot and the actual cut-over date).

Prerequisites: a POSIX shell, `curl`, GNU coreutils (`sha256sum`, `du`, `awk`).

```bash
export MATOMO_TOKEN="<auth-token-with-read-access-to-site-7>"
bash matomo_export.sh
```

Output is written to a fresh `matomo_export_<timestamp>/` folder. The script does not overwrite previous exports.

The auth token can be generated from the Matomo UI: top-right username menu, then **Personal** > **Security**, section **Auth tokens**, **Create new token**. Read access on site 7 is sufficient.

If the Matomo instance is decommissioned before all data is exported, the underlying MySQL database (`matomo_*` tables) remains the canonical source. The `matomo_log_visit`, `matomo_log_link_visit_action`, `matomo_log_action`, and `matomo_log_conversion` tables hold the raw, unaggregated data and can be queried directly.

## File encoding and format

All CSV files are UTF-8 encoded with comma separators and a header row. They open directly in Excel, LibreOffice Calc, Google Sheets, and any pandas or R workflow. JSON configuration files follow the standard Matomo Reporting API response format.

## Contact

For questions about this archive, the export procedure, or the historical Matomo configuration, please contact the IT team at The Lisbon Council (BridgeGap project coordinator).

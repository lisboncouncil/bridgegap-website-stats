#!/bin/bash
# ==========================================================================
# Matomo CSV exporter (curl-based)
# Site: https://lisboncouncilresearch.com/matomo/  (idSite=7)
# Range: 2024-02-21 (inizio tracking) -> oggi
#
# Uso:
#   export MATOMO_TOKEN="il_tuo_token_auth"
#   bash matomo_export.sh
#
# Output: cartella ./matomo_export_<timestamp>/
# ==========================================================================

TOKEN="${MATOMO_TOKEN:?Imposta la variabile MATOMO_TOKEN}"
ENDPOINT="https://lisboncouncilresearch.com/matomo/"
B="?module=API&idSite=7&language=en&token_auth=${TOKEN}"
R="2024-02-21,2026-05-08"

OUT="matomo_export_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT"
cd "$OUT" || exit 1

echo "Output dir: $(pwd)"
echo

# Funzione di fetch con check minimo
fetch() {
  local out="$1" desc="$2" url="$3"
  local data="${url#\?}"
  if curl -fsS -X POST "$ENDPOINT" --data "$data" -o "$out"; then
    local size
    size=$(wc -c < "$out")
    printf "  OK   %-40s  %8d bytes  %s\n" "$out" "$size" "$desc"
  else
    printf "  FAIL %-40s  %s\n" "$out" "$desc"
  fi
}

echo "=== 1. Overview / serie temporali ==="
fetch "01_overview_daily.csv"   "VisitsSummary daily"   "$B&format=CSV&method=VisitsSummary.get&period=day&date=$R"
fetch "02_overview_weekly.csv"  "VisitsSummary weekly"  "$B&format=CSV&method=VisitsSummary.get&period=week&date=$R"
fetch "03_overview_monthly.csv" "VisitsSummary monthly" "$B&format=CSV&method=VisitsSummary.get&period=month&date=$R"

echo
echo "=== 2. Acquisizione ==="
fetch "10_channels.csv"            "Referrer types"     "$B&format=CSV&method=Referrers.getReferrerType&period=range&date=$R"
fetch "11_referrers_all.csv"       "All referrers"      "$B&format=CSV&method=Referrers.getAll&period=range&date=$R&filter_limit=1000"
fetch "12_referrers_websites.csv"  "Websites"           "$B&format=CSV&method=Referrers.getWebsites&period=range&date=$R&filter_limit=500&expanded=1"
fetch "13_search_engines.csv"      "Search engines"     "$B&format=CSV&method=Referrers.getSearchEngines&period=range&date=$R&filter_limit=200"
fetch "14_keywords.csv"            "Keywords"           "$B&format=CSV&method=Referrers.getKeywords&period=range&date=$R&filter_limit=500"
fetch "15_socials.csv"             "Socials"            "$B&format=CSV&method=Referrers.getSocials&period=range&date=$R&filter_limit=200"
fetch "16_campaigns.csv"           "Campaigns UTM"      "$B&format=CSV&method=Referrers.getCampaigns&period=range&date=$R&filter_limit=500"

echo
echo "=== 3. Comportamento / Pagine ==="
fetch "20_pages_urls.csv"          "Page URLs"          "$B&format=CSV&method=Actions.getPageUrls&period=range&date=$R&filter_limit=2000&flat=1"
fetch "21_pages_titles.csv"        "Page Titles"        "$B&format=CSV&method=Actions.getPageTitles&period=range&date=$R&filter_limit=1000"
fetch "22_entry_pages.csv"         "Entry pages"        "$B&format=CSV&method=Actions.getEntryPageUrls&period=range&date=$R&filter_limit=200&flat=1"
fetch "23_exit_pages.csv"          "Exit pages"         "$B&format=CSV&method=Actions.getExitPageUrls&period=range&date=$R&filter_limit=200&flat=1"
fetch "24_outlinks.csv"            "Outlinks"           "$B&format=CSV&method=Actions.getOutlinks&period=range&date=$R&filter_limit=500&flat=1"
fetch "25_downloads.csv"           "Downloads"          "$B&format=CSV&method=Actions.getDownloads&period=range&date=$R&filter_limit=500&flat=1"
fetch "26_site_search_kw.csv"      "Site search kw"     "$B&format=CSV&method=Actions.getSiteSearchKeywords&period=range&date=$R&filter_limit=500"
fetch "27_site_search_no_res.csv"  "Search no results"  "$B&format=CSV&method=Actions.getSiteSearchNoResultKeywords&period=range&date=$R&filter_limit=500"

echo
echo "=== 4. Eventi ==="
fetch "30_events_category.csv"     "Events category"    "$B&format=CSV&method=Events.getCategory&period=range&date=$R&filter_limit=200"
fetch "31_events_action.csv"       "Events action"      "$B&format=CSV&method=Events.getAction&period=range&date=$R&filter_limit=200"
fetch "32_events_name.csv"         "Events name"        "$B&format=CSV&method=Events.getName&period=range&date=$R&filter_limit=500"

echo
echo "=== 5. Geografia ==="
fetch "40_countries.csv"           "Countries"          "$B&format=CSV&method=UserCountry.getCountry&period=range&date=$R&filter_limit=250"
fetch "41_regions.csv"             "Regions"            "$B&format=CSV&method=UserCountry.getRegion&period=range&date=$R&filter_limit=200"
fetch "42_cities.csv"              "Cities"             "$B&format=CSV&method=UserCountry.getCity&period=range&date=$R&filter_limit=500"

echo
echo "=== 6. Device / Software ==="
fetch "50_device_type.csv"         "Device type"        "$B&format=CSV&method=DevicesDetection.getType&period=range&date=$R"
fetch "51_device_brand.csv"        "Device brand"       "$B&format=CSV&method=DevicesDetection.getBrand&period=range&date=$R&filter_limit=100"
fetch "52_device_model.csv"        "Device model"       "$B&format=CSV&method=DevicesDetection.getModel&period=range&date=$R&filter_limit=200"
fetch "53_os_family.csv"           "OS family"          "$B&format=CSV&method=DevicesDetection.getOsFamilies&period=range&date=$R"
fetch "54_browsers.csv"            "Browsers"           "$B&format=CSV&method=DevicesDetection.getBrowsers&period=range&date=$R&filter_limit=100"
fetch "55_resolutions.csv"         "Resolutions"        "$B&format=CSV&method=Resolution.getResolution&period=range&date=$R&filter_limit=100"

echo
echo "=== 7. Engagement ==="
fetch "60_visit_frequency.csv"     "Visit frequency"    "$B&format=CSV&method=VisitFrequency.get&period=range&date=$R"
fetch "61_visit_duration.csv"      "Visit duration"     "$B&format=CSV&method=VisitorInterest.getNumberOfVisitsPerVisitDuration&period=range&date=$R"
fetch "62_pages_per_visit.csv"     "Pages per visit"    "$B&format=CSV&method=VisitorInterest.getNumberOfVisitsPerPage&period=range&date=$R"
fetch "63_days_since_last.csv"     "Days since last"    "$B&format=CSV&method=VisitorInterest.getNumberOfVisitsByDaysSinceLast&period=range&date=$R"
fetch "64_visits_by_count.csv"     "Visits by count"    "$B&format=CSV&method=VisitorInterest.getNumberOfVisitsByVisitCount&period=range&date=$R"

echo
echo "=== 8. Goals ==="
fetch "70_goals_overall.csv"       "Goals overall"      "$B&format=CSV&method=Goals.get&period=range&date=$R"
fetch "71_goals_monthly.csv"       "Goals monthly"      "$B&format=CSV&method=Goals.get&period=month&date=$R"
fetch "72_goals_days_to_conv.csv"  "Days to conversion" "$B&format=CSV&method=Goals.getDaysToConversion&period=range&date=$R"
fetch "73_goals_visits_to_conv.csv" "Visits to conv"    "$B&format=CSV&method=Goals.getVisitsUntilConversion&period=range&date=$R"

echo
echo "=== 9. Configurazione (JSON) ==="
fetch "config_goals.json"               "Goals config"           "$B&format=JSON&method=Goals.getGoals"
fetch "config_site.json"                "Site config"            "$B&format=JSON&method=SitesManager.getSiteFromId"
fetch "config_custom_dimensions.json"   "Custom dimensions"      "$B&format=JSON&method=CustomDimensions.getConfiguredCustomDimensions"
fetch "config_segments.json"            "Saved segments"         "$B&format=JSON&method=SegmentEditor.getAll"
fetch "config_users_access.json"        "Users access"           "$B&format=JSON&method=UsersManager.getUsersAccessFromSite"

echo
echo "=== Manifest e checksums ==="

# SHA256SUMS: machine-readable, verificabile con `sha256sum -c SHA256SUMS`
sha256sum *.csv *.json > SHA256SUMS
echo "  OK   SHA256SUMS"

# MANIFEST.txt: header documentale + checksums per consultazione umana
{
  echo "Matomo Export Manifest"
  echo "======================"
  echo
  echo "Site:        lisboncouncilresearch.com (Matomo idSite=7)"
  echo "Tracking:    started 2024-02-21"
  echo "Range:       $R"
  echo "Exported on: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  echo "Host:        $(hostname)"
  echo "Files:       $(ls -1 *.csv *.json 2>/dev/null | wc -l)"
  echo "Total bytes: $(du -bc *.csv *.json 2>/dev/null | tail -1 | awk '{print $1}')"
  echo
  echo "Verify integrity (from inside this folder):"
  echo "    sha256sum -c SHA256SUMS"
  echo
  echo "SHA256 checksums"
  echo "----------------"
  cat SHA256SUMS
} > MANIFEST.txt
echo "  OK   MANIFEST.txt"

echo
echo "Done. Files in: $(pwd)"
ls -lh

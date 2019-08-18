importScripts('/assets/js/babel-polyfill.js');

const CONCEPTS_URL = '/api/concepts-index-list.json';

const LANGUAGES = [
  'eng',
  'ara',
  'spa',
  'swe',
  'kor',
  'rus',
  'ger',
  'fre',
  'fin',
  'jpn',
  'dan',
  'chi',
];

var concepts = null;
var latestQuery = null;

function fetchConcepts() {
  if (concepts === null) {
    concepts = fetch(CONCEPTS_URL).then((resp) => resp.json());
  }
  return concepts;
}

async function filterAndSort(params) {
  var concepts = await fetchConcepts();

  if (params.string !== '') {
    concepts = concepts.map((_item) => {
      // Search all localized term names for the presence of given search string

      const item = Object.assign({}, _item);
      const queryString = params.string.toLowerCase();
      const matchingLanguages = LANGUAGES.
        filter((lang) => {
          const term = (item[lang] || {}).term;
          return term && term.toLowerCase().indexOf(params.string) >= 0;
        });

      if (matchingLanguages.length > 0) {
        for (let lang of LANGUAGES) {
          if (matchingLanguages.indexOf(lang) < 0) {
            delete item[lang];
          }
        }
        return item;
      } else {
        return null;
      }
    }).filter((item) => item !== null);
  }

  if (params.valid !== undefined) {
    concepts = concepts.
      filter((item) => {
        // Only select concepts with at least one localized version matching given validity query
        const validLocalizedItems = LANGUAGES.
          filter((lang) => item.hasOwnProperty(lang)).
          filter((lang) => item[lang].entry_status === params.valid);
        return validLocalizedItems.length > 0;
      }).
      map((_item) => {
        // Delete localized versions that don’t match given validity query

        const item = Object.assign({}, _item);
        for (let lang of LANGUAGES) {
          if (item[lang] && item[lang].entry_status !== params.valid) {
            delete item[lang];
          }
        }
        return item;
      });
  }

  return concepts.sort((item1, item2) => item1.termid - item2.termid);
}

onmessage = async function(msg) {
  latestQuery = msg.data;

  let concepts;
  try {
    concepts = await filterAndSort(msg.data);
  } catch (e) {
    console.error(e);
    postMessage({ error: "Failed to fetch concepts, please <a href='javascript:window.location.reload();'>reload</a> & try again!" });
    throw e;
    return;
  }

  // Check if we the query changed while concepts were being fetched,
  // in that case skip posting back the message
  // NOTE: if more query parameters are supported, update the condition to ensure
  // full comparison
  if (latestQuery.string === msg.data.string) {
    postMessage(concepts);
  }
};

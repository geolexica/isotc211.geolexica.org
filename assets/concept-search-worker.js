const CONCEPTS_URL = '/concepts.json';

const LANGUAGES = [
  'eng',
  'ara',
  'spa',
  'swe',
  'kor',
];

var concepts = null;
var conceptsWereRequested = false;
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
    concepts = concepts.map((item) => {
      // Search all localized term names for the presence of given search string

      let matchingLanguages = LANGUAGES.
        filter((lang) => item[lang] && item[lang].term.indexOf(params.string) >= 0);

      if (matchingLanguages.length > 0) {
        for (let lang of LANGUAGES) {
          if (matchingLanguages.indexOf(lang) < 0) {
            delete item[lang];
          }
        }
        return item;
      }
      return null;
    }).filter((item) => item !== null);
  }

  if (params.valid !== undefined) {
    concepts = concepts.
      filter((item) => {
        // Only select concepts with at least one localized version matching given validity query
        let validLocalizedItems = LANGUAGES.
          filter((lang) => item.hasOwnProperty(lang)).
          filter((lang) => item[lang].entry_status === (params.valid ? 'valid' : 'notValid'));
        return validLocalizedItems.length > 0;
      }).
      map((item) => {
        // Delete localized versions that don’t match given validity query
        for (let lang of LANGUAGES) {
          if (item[lang] && item[lang].entry_status !== (params.valid ? 'valid' : 'notValid')) {
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

  let concepts = await filterAndSort(msg.data);

  // Check if we got a new message while concepts were being fetched,
  // in that case 
  if (latestQuery.string === msg.data.string) {  // UPDATE if more parameters are supported
    postMessage(concepts);
  }
};

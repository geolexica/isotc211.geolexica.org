---
---

{% if site.algolia %}
  // Instanciating InstantSearch.js with Algolia credentials
  var search = instantsearch({
    appId: '{{ site.algolia.application_id }}',
    indexName: '{{ site.algolia.index_name }}',
    apiKey: '{{ site.algolia.search_only_api_key }}'
  });

  // Adding searchbar and results widgets
  search.addWidget(
    instantsearch.widgets.searchBox({
      container: '#search-searchbar',
      placeholder: 'Search into posts...',
      poweredBy: true // This is required if you're on the free Community plan
    })
  );
  search.addWidget(
    instantsearch.widgets.hits({
      container: '#search-hits'
    })
  );

  // Starting the search
  search.start();
{% endif %}

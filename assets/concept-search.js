(function () {

  const searchWorker = new Worker('/assets/concept-search-worker.js');

  // TODO: Move to a shared module
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


  // React-based concept browser
  // ===========================

  let el = React.createElement;

  function maybeConceptLinkForField(fieldName) {
    return (concept) => {
      const link = getConceptPermalink(concept);
      if (link) {
        return el('a', { href: link, target: '_blank', }, concept[fieldName]);
      } else {
        return el('span', null, concept[fieldName]);
      }
    }
  }

  let fieldConfig = {
    termid: { title: 'Ref', view: maybeConceptLinkForField('termid'), },
    term: { title: 'Term', view: maybeConceptLinkForField('term'), },
    language_code: { title: 'Lang' },
    entry_status: { title: 'Validity' },
    review_decision: { title: 'Review' },
  };

  let fields = ['termid', 'language_code', 'term', 'entry_status', 'review_decision'].map((f) => {
    return { name: f, ...fieldConfig[f] };
  });

  class SearchControls extends React.Component {
    constructor(props) {
      super();

      this.handleSearchStringChange = this.handleSearchStringChange.bind(this);
      this.handleValiditySelectionChange = this.handleValiditySelectionChange.bind(this);

      this.stringInputRef = React.createRef();

      this.state = {
        valid: undefined,  // Required value of the entry_status field, or undefined
        string: '',
      };
    }
    componentDidMount() {
      this.stringInputRef.current.focus();
    }
    render() {
      var searchControls = [
        el('input', {
          key: 'search-string',
          ref: this.stringInputRef,
          className: 'search-string',
          type: 'text',
          placeholder: 'Start typing…',
          onChange: this.handleSearchStringChange}),
      ];

      if (this.state.string.length > 1 && (this.props.refineControls || []).length > 0) {
        var refineControls = [];

        if (this.props.refineControls.indexOf('validity') >= 0) {
          refineControls.push(
            el('div', { key: 'validity', className: 'validity' }, [
              el('input', {
                key: 'validity-checkbox',
                id: 'conceptSearchValidity',
                type: 'checkbox',
                checked: this.state.valid === 'valid' || false,
                onChange: this.handleValiditySelectionChange}),
              el('label', {
                key: 'validity-label',
                htmlFor: 'conceptSearchValidity' }, 'valid only'),
            ]),
          )
        }

        searchControls.push(el('div', { key: 'refine', className: 'refine' }, refineControls));
      }

      return el(React.Fragment, null, searchControls);
    }

    emitSearchChange() {
      this.props.onSearchChange({
        valid: this.state.valid,
        string: this.state.string,
      });
    }

    handleSearchStringChange(evt) {
      this.setState({ string: evt.target.value }, () => { this.emitSearchChange() });
    }

    handleValiditySelectionChange(evt) {
      this.setState(({ valid, string }) => {
        if (valid === 'valid') {
          return { valid: undefined, string };
        } else {
          return { valid: 'valid', string };
        }
      }, () => { this.emitSearchChange() });
    }
  }

  class ConceptList extends React.Component {
    render() {
      return el('table', null, [

        el('thead', { key: 'thead' }, el('tr', null, this.props.fields.map((field) => {
          return el('th', { key: field.name }, field.title);
        }))),

        el('tbody', { key: 'tbody' }, this.props.items.map((item) => {
          const localizedItems = LANGUAGES.
            filter((lang) => Object.keys(item).indexOf(lang) >= 0).
            map((lang) => item[lang]);

          return [item, ...localizedItems].map((item) => {
            const isLocalized = item.hasOwnProperty('language_code');
            const conceptId = isLocalized ? item.id : item.termid;

            return el(
              'tr', {
                key: `${conceptId}-${item.language_code}`,
                className: `${isLocalized ? 'localized' : 'main'}`,
              },
              this.props.fields.map((field) => {
                const view = field.view;
                const defaultView = (item) => { return item[field.name]; };
                return el(
                  'td',
                  { key: `${conceptId}-${item.language_code}-${field.name}` },
                  (view || defaultView)(item));
              })
            );
          });
        }).reduce((a, b) => a.concat(b), [])),

      ]);
    }
  }

  class ConceptBrowser extends React.Component {
    constructor(props) {
      super();

      this.state = {
        items: [],
        searchQuery: {},  // string, (in future) valid
        expanded: false,
        error: false,
        loading: false,
      };

      this.handleSearchQuery = this.handleSearchQuery.bind(this);
      this.handleToggleBrowser = this.handleToggleBrowser.bind(this);
    }

    componentDidMount() {
      searchWorker.onmessage = (msg) => {
        if (msg.data.error) {
          this.setState({ loading: false, error: msg.data.error });
        } else {
          this.setState({ loading: false, error: null, items: msg.data });
        }
      };
    }

    componentWillUnmount() {
      searchWorker.onmessage = undefined;
    }

    render() {
      var headerEls = [];
      var searchString = this.state.searchQuery.string;

      if (searchString && searchString.length > 1) {
        let buttonLabel = this.state.expanded ? '×' : '+';
        headerEls.push(
          el('button', {
            key: 'toggle',
            ref: this.toggleSwitchRef,
            className: 'toggle',
            onClick: this.handleToggleBrowser,
          }, buttonLabel)
        );
      }
      headerEls.push(el('span', { key: 'title' }, 'Find a concept'));
      headerEls.push(el('a', { key: 'link', href: '/concepts' }, '(browse all)'));

      var els = [
        el('h2', { key: 'section-title', className: 'section-title' }, headerEls),
        el('div', { key: 'search-controls', className: 'search-controls' },
          el(SearchControls, {
            onSearchChange: this.handleSearchQuery,
            refineControls: ['validity'],
          })
        ),
      ];

      if (this.state.error) {
        els.push(el(
          'div',
          { key: 'search-results', className: 'search-results status-message error' },
          this.state.error));
      } else if (this.state.loading) {
        els.push(el(
          'div',
          { key: 'search-results', className: 'search-results status-message loading' },
          'Loading…'));
      } else if (this.state.expanded) {
        els.push(el(
          'div',
          { key: 'search-results', className: 'search-results' },
          el(ConceptList, { items: this.state.items, fields })));
      }

      return el(React.Fragment, null, els);
    }

    handleSearchQuery(query) {
      var hasQuery = query.string.length > 1;
      if (hasQuery) {
        window.setTimeout(() => { searchWorker.postMessage(query) }, 100);
      }
      this.setState({ loading: hasQuery, searchQuery: query, expanded: hasQuery });
      updateBodyClass({ searchQuery: query, expanded: hasQuery });
    }

    handleToggleBrowser() {
      this.setState((state) => {
        state.expanded = !state.expanded;
        updateBodyClass({ expanded: state.expanded });
        return state;
      });
    }
  }

  ReactDOM.render(el(ConceptBrowser, null), document.querySelector('.browse-concepts'))

  function getConceptPermalink(concept) {
    if (concept.termid) {
      return `/concepts/${concept.termid}/`;
    } else if (concept.id && concept.language_code) {
      return `/concepts/${concept.id}/#entry-lang-${concept.language_code}`;
    } else {
      return null;
    }
  }

  function updateBodyClass({ searchQuery, expanded }) {
    if (searchQuery) {
      if (searchQuery.string.length > 1) {
        document.querySelector('body').classList.add('browser-expandable');
      } else {
        document.querySelector('body').classList.remove('browser-expandable');
      }
    }

    if (expanded === true) {
      document.querySelector('body').classList.add('browser-expanded');
    } else if (expanded === false) {
      document.querySelector('body').classList.remove('browser-expanded');
    }
  }

}());

export const showSuggestionsHolder = state => state.suggestions.length || state.isLoading;
export const showSuggestions = state => state.suggestions.length && !state.isLoading;

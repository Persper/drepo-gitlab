import { gql } from 'apollo-boost';

export default gql`
  query($fullPath: ID!, $search: String) {
    project(fullPath: $fullPath) {
      issues(search: $search, limit: 5) {
        iid
        title
        userNotesCount
        upvotes
      }
    }
  }
`;

// App.test.js
//
import React from 'react';
import { render } from '@testing-library/react';
import App from './App';

test('renders PF9 Activation link', () => {
  const { getByText } = render(<App />);
  const linkElement = getByText(/Activate Your Platform9/i);
  expect(linkElement).toBeInTheDocument();
});

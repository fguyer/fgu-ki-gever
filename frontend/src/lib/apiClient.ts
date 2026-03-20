import { ApiRequestOptions } from '../types/api';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8000';

export async function apiClient<TResponse>(
  path: string,
  options: ApiRequestOptions = {}
): Promise<TResponse> {
  const { method = 'GET', body, headers } = options;

  const response = await fetch(`${API_BASE_URL}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...headers
    },
    body: body !== undefined ? JSON.stringify(body) : undefined
  });

  if (!response.ok) {
    throw new Error(`API request failed with status ${response.status}`);
  }

  return (await response.json()) as TResponse;
}

import { PropsWithChildren } from 'react';
import { NavLink } from 'react-router-dom';

export function AppLayout({ children }: PropsWithChildren) {
  return (
    <div className="app-shell">
      <header>
        <h1>FGU KI GEVER</h1>
        <nav className="main-nav">
          <NavLink to="/login">Login</NavLink>
          <NavLink to="/dashboard">Dashboard</NavLink>
          <NavLink to="/tree">Tree</NavLink>
        </nav>
      </header>
      <main>{children}</main>
    </div>
  );
}

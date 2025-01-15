(function () {
    // Set theme based on user preference
    const savedTheme = localStorage.getItem('theme');
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const theme = savedTheme || (prefersDark ? 'dark' : 'light');
    document.documentElement.setAttribute('data-theme', theme);

    // Set dynamic favicon
    const favicon = document.querySelector('link[rel="icon"]');
    favicon.href = './images/favicon-' + theme + '.ico';
})();
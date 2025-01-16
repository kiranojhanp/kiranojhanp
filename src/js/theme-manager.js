class ThemeManager {
    constructor(audioService) {
        this.audioService = audioService;
        this.themeToggle = document.querySelector('.theme-toggle');
        this.initialize();
    }

    initialize() {
        // Initialize theme toggle listener if element exists
        if (this.themeToggle) {
            this.themeToggle.addEventListener('click', () => this.handleThemeToggle());
        }
    }

    static preloadTheme() {
        const savedTheme = localStorage.getItem('theme');
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        const theme = savedTheme || (prefersDark ? 'dark' : 'light');

        ThemeManager.applyTheme(theme);
    }

    static applyTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);

        const favicon = document.querySelector('link[rel="icon"]');
        if (favicon) {
            favicon.href = `/images/favicon-${theme}.ico`;
        }
    }

    async handleThemeToggle() {
        const currentTheme = document.documentElement.getAttribute('data-theme');
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';

        ThemeManager.applyTheme(newTheme);
        localStorage.setItem('theme', newTheme);
        await this.audioService.playClickSound();
    }
}
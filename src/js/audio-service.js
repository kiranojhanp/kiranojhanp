class AudioService {
    constructor() {
        this.audioContext = null;
        this.isInitialized = false;
    }

    async initialize() {
        if (this.isInitialized) return;

        try {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
            this.isInitialized = true;
        } catch (error) {
            console.error('Failed to initialize AudioContext:', error);
        }
    }

    async playClickSound() {
        if (!this.isInitialized) {
            await this.initialize();
        }

        try {
            const oscillator = this.audioContext.createOscillator();
            const gainNode = this.audioContext.createGain();

            oscillator.type = 'square';
            oscillator.frequency.setValueAtTime(2000, this.audioContext.currentTime);
            oscillator.frequency.exponentialRampToValueAtTime(
                1,
                this.audioContext.currentTime + 0.05
            );

            gainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
            gainNode.gain.linearRampToValueAtTime(0.3, this.audioContext.currentTime + 0.005);
            gainNode.gain.linearRampToValueAtTime(0, this.audioContext.currentTime + 0.05);

            oscillator.connect(gainNode);
            gainNode.connect(this.audioContext.destination);

            oscillator.start();
            oscillator.stop(this.audioContext.currentTime + 0.05);
        } catch (error) {
            console.error('Failed to play click sound:', error);
        }
    }
}
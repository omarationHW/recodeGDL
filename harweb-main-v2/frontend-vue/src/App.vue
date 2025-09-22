<template>
  <div id="app">
    <MainLayout>
      <router-view />
    </MainLayout>
  </div>
</template>

<script>
import MainLayout from './layouts/MainLayout.vue'

export default {
  name: 'App',
  components: {
    MainLayout
  }
}
</script>

<style>
/* Sistema Municipal de Guadalajara */
@import '@/styles/municipal-theme.css';
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

#app {
  font-family: 'Inter', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: var(--slate-700);
  background: #f8fafc;
  min-height: 100vh;
}

/* Global Styles */
* {
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  margin: 0;
  padding: 0;
  overflow-x: hidden;
}

/* Button Styles */
.btn {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  border: none;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s ease;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.btn-primary {
  background: var(--municipal-blue);
  color: white;
}

.btn-primary:hover {
  background: var(--municipal-blue-dark);
}

.btn-secondary {
  background: var(--slate-100);
  color: var(--slate-700);
}

.btn-secondary:hover {
  background: var(--slate-200);
}

/* 📱 Responsive Typography */
@media (max-width: 768px) {
  html {
    font-size: 14px;
  }
}

/* 🌙 Dark Mode */
@media (prefers-color-scheme: dark) {
  #app {
    background: linear-gradient(135deg, var(--slate-900) 0%, var(--slate-800) 100%);
    color: var(--slate-200);
  }
}

/* 🎯 Animaciones de Entrada */
@keyframes appFadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

#app {
  animation: appFadeIn 0.6s ease-out;
}

/* 🏛️ Elementos Municipales */
.municipal-card {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: var(--radius-xl);
  padding: var(--space-xl);
  box-shadow: var(--shadow-glass);
  transition: all var(--transition-normal);
}

.municipal-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-elevation);
}

/* ✨ Efectos de Loading */
.loading-shimmer {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

/* 🎪 Confeti Municipal */
.confetti {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  pointer-events: none;
  z-index: 9999;
}

.confetti-piece {
  position: absolute;
  width: 10px;
  height: 10px;
  background: var(--gdl-gold);
  animation: confetti-fall 3s linear infinite;
}

@keyframes confetti-fall {
  to {
    transform: translateY(100vh) rotate(360deg);
  }
}
</style>
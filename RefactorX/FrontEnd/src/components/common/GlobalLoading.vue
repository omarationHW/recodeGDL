<template>
  <Transition name="fade">
    <div v-if="isLoading" class="global-loading-overlay">
      <div class="global-loading-content">
        <div class="global-loading-logo-wrapper">
          <img src="/logo1.png?v=2" alt="Cargando..." class="global-loading-logo" />
        </div>
        <p class="global-loading-text">{{ loadingMessage }}</p>
        <div v-if="loadingSubMessage" class="global-loading-submessage">{{ loadingSubMessage }}</div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { isLoading, loadingMessage, loadingSubMessage } = useGlobalLoading()
</script>

<style>
/* Loading Global - Siempre fullscreen, usado en todo el sitio */
.global-loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 99999;
}

.global-loading-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.global-loading-logo-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 250px;
  height: 250px;
}

.global-loading-logo-wrapper::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 220px;
  height: 220px;
  border-radius: 50%;
  background: radial-gradient(circle at center,
    rgba(234, 130, 21, 0.35) 0%,
    rgba(234, 130, 21, 0.25) 20%,
    rgba(204, 159, 82, 0.2) 35%,
    rgba(255, 183, 0, 0.15) 50%,
    rgba(234, 130, 21, 0.1) 65%,
    rgba(204, 159, 82, 0.05) 80%,
    transparent 100%
  );
  animation: glow-expand 2.5s ease-in-out infinite;
  filter: blur(12px);
  z-index: 0;
}

.global-loading-logo {
  width: 120px;
  height: auto;
  animation: pulse-loading 1.5s ease-in-out infinite;
  filter: drop-shadow(0 4px 12px rgba(234, 130, 21, 0.3))
         drop-shadow(0 8px 20px rgba(204, 159, 82, 0.25))
         drop-shadow(0 0 30px rgba(255, 183, 0, 0.2));
  position: relative;
  z-index: 2;
}

@keyframes pulse-loading {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.8;
    transform: scale(0.95);
  }
}

@keyframes glow-expand {
  0% {
    transform: translate(-50%, -50%) scale(0.85);
    opacity: 0.6;
  }
  50% {
    transform: translate(-50%, -50%) scale(1);
    opacity: 1;
  }
  100% {
    transform: translate(-50%, -50%) scale(0.85);
    opacity: 0.6;
  }
}

.global-loading-text {
  color: white;
  font-size: 20px;
  font-weight: 600;
  margin: 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
  letter-spacing: 0.5px;
}

.global-loading-submessage {
  font-size: 15px;
  color: rgba(255, 255, 255, 0.85);
  margin-top: -10px;
  font-weight: 500;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

/* Animación de entrada/salida */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>

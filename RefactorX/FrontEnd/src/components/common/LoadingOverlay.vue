<template>
  <Transition name="fade">
    <div v-if="show" class="loading-overlay-global" :class="{ 'loading-fullscreen': fullscreen }">
      <div class="loading-content-global">
        <img src="/logo1.png?v=2" alt="Cargando..." class="loading-logo-global" />
        <p class="loading-text-global">{{ message }}</p>
        <div v-if="subMessage" class="loading-submessage">{{ subMessage }}</div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
defineProps({
  show: {
    type: Boolean,
    default: false
  },
  message: {
    type: String,
    default: 'Cargando...'
  },
  subMessage: {
    type: String,
    default: ''
  },
  fullscreen: {
    type: Boolean,
    default: false
  }
})
</script>

<style>
/* Loading Overlay Global - Estilo original bonito */
.loading-overlay-global {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  border-radius: 8px;
}

.loading-overlay-global.loading-fullscreen {
  position: fixed;
  border-radius: 0;
}

.loading-content-global {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.loading-logo-global {
  width: 120px;
  height: auto;
  animation: pulse-logo 1.5s ease-in-out infinite;
  filter: drop-shadow(0 4px 12px rgba(255, 255, 255, 0.3));
}

@keyframes pulse-logo {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.8;
    transform: scale(0.95);
  }
}

.loading-text-global {
  color: white;
  font-size: 20px;
  font-weight: 600;
  margin: 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
  letter-spacing: 0.5px;
}

.loading-submessage {
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

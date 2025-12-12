<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="show" class="modal-overlay" @click="closeModal">
        <div class="modal-container" @click.stop>
          <div class="modal-header" :class="headerClass">
            <h3 class="modal-title">
              <font-awesome-icon :icon="iconType" />
              {{ title }}
            </h3>
            <button class="modal-close" @click="closeModal" aria-label="Cerrar">
              <font-awesome-icon icon="times" />
            </button>
          </div>
          <div class="modal-body">
            <p>{{ message }}</p>
          </div>
          <div class="modal-footer">
            <button class="btn-modal-primary" @click="closeModal">
              Aceptar
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: 'Mensaje'
  },
  message: {
    type: String,
    default: ''
  },
  type: {
    type: String,
    default: 'success',
    validator: (value) => ['success', 'error', 'warning', 'info'].includes(value)
  }
})

const emit = defineEmits(['close'])

const headerClass = computed(() => {
  const classes = {
    success: 'modal-header-success',
    error: 'modal-header-error',
    warning: 'modal-header-warning',
    info: 'modal-header-info'
  }
  return classes[props.type] || classes.success
})

const iconType = computed(() => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[props.type] || icons.success
})

function closeModal() {
  emit('close')
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  backdrop-filter: blur(2px);
}

.modal-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  max-width: 500px;
  width: 90%;
  overflow: hidden;
  animation: modalSlideIn 0.3s ease-out;
}

.modal-header {
  padding: 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
  position: relative;
}

.modal-header-success {
  background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
}

.modal-header-error {
  background: linear-gradient(135deg, #ee0979 0%, #ff6a00 100%);
}

.modal-header-warning {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.modal-header-info {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.modal-title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.modal-close {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.modal-close:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

.modal-body {
  padding: 2rem 1.5rem;
  color: #333;
  font-size: 1rem;
  line-height: 1.6;
}

.modal-body p {
  margin: 0;
}

.modal-footer {
  padding: 1rem 1.5rem;
  background-color: #f8f9fa;
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  border-top: 1px solid #dee2e6;
}

.btn-modal-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 0.75rem 2rem;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.btn-modal-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.btn-modal-primary:active {
  transform: translateY(0);
}

/* Transiciones */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .modal-container,
.modal-leave-active .modal-container {
  transition: transform 0.3s ease;
}

.modal-enter-from .modal-container,
.modal-leave-to .modal-container {
  transform: scale(0.9);
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

@media (max-width: 768px) {
  .modal-container {
    max-width: 95%;
  }

  .modal-header {
    padding: 1rem;
  }

  .modal-title {
    font-size: 1.1rem;
  }

  .modal-body {
    padding: 1.5rem 1rem;
    font-size: 0.95rem;
  }

  .modal-footer {
    padding: 0.75rem 1rem;
  }

  .btn-modal-primary {
    padding: 0.6rem 1.5rem;
    font-size: 0.95rem;
  }
}
</style>

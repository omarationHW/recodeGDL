<template>
  <Transition name="modal">
    <div v-if="show" class="modal-overlay" @click="handleOverlayClick">
      <div class="modal-container" @click.stop>
        <div class="modal-header" :class="headerClass">
          <div class="modal-icon">
            <font-awesome-icon :icon="icon" />
          </div>
          <h3 class="modal-title">{{ title }}</h3>
          <button class="modal-close" @click="close">
            <font-awesome-icon icon="times" />
          </button>
        </div>

        <div class="modal-body">
          <p class="modal-message">{{ message }}</p>
          <slot></slot>
        </div>

        <div class="modal-footer">
          <button
            v-if="showCancel"
            class="btn-modal-secondary"
            @click="cancel"
          >
            {{ cancelText }}
          </button>
          <button
            class="btn-modal-primary"
            :class="buttonClass"
            @click="confirm"
          >
            {{ confirmText }}
          </button>
        </div>
      </div>
    </div>
  </Transition>
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
    default: 'success', // success, error, warning, info
    validator: (value) => ['success', 'error', 'warning', 'info'].includes(value)
  },
  confirmText: {
    type: String,
    default: 'Aceptar'
  },
  cancelText: {
    type: String,
    default: 'Cancelar'
  },
  showCancel: {
    type: Boolean,
    default: false
  },
  closeOnOverlay: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['close', 'confirm', 'cancel'])

const icon = computed(() => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[props.type] || 'info-circle'
})

const headerClass = computed(() => {
  return `modal-header-${props.type}`
})

const buttonClass = computed(() => {
  return `btn-modal-${props.type}`
})

function close() {
  emit('close')
}

function confirm() {
  emit('confirm')
  close()
}

function cancel() {
  emit('cancel')
  close()
}

function handleOverlayClick() {
  if (props.closeOnOverlay) {
    close()
  }
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
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.modal-container {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow: auto;
}

.modal-header {
  display: flex;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
  gap: 1rem;
}

.modal-header-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  color: white;
}

.modal-header-error {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
}

.modal-header-warning {
  background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
  color: white;
}

.modal-header-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
  color: white;
}

.modal-icon {
  font-size: 1.5rem;
  flex-shrink: 0;
}

.modal-title {
  flex: 1;
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
}

.modal-close {
  background: none;
  border: none;
  color: inherit;
  font-size: 1.25rem;
  cursor: pointer;
  padding: 0.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.modal-close:hover {
  background-color: rgba(255, 255, 255, 0.2);
}

.modal-body {
  padding: 2rem 1.5rem;
}

.modal-message {
  margin: 0;
  font-size: 1rem;
  line-height: 1.5;
  color: #333;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  padding: 1rem 1.5rem;
  border-top: 1px solid #e0e0e0;
  background-color: #f8f9fa;
}

.btn-modal-primary,
.btn-modal-secondary {
  padding: 0.625rem 1.5rem;
  border: none;
  border-radius: 4px;
  font-size: 0.9375rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-modal-primary {
  color: white;
}

.btn-modal-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
}

.btn-modal-success:hover {
  background: linear-gradient(135deg, #218838 0%, #1ea87a 100%);
  box-shadow: 0 2px 8px rgba(40, 167, 69, 0.3);
}

.btn-modal-error {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
}

.btn-modal-error:hover {
  background: linear-gradient(135deg, #c82333 0%, #bd2130 100%);
  box-shadow: 0 2px 8px rgba(220, 53, 69, 0.3);
}

.btn-modal-warning {
  background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
  color: #333;
}

.btn-modal-warning:hover {
  background: linear-gradient(135deg, #e0a800 0%, #fb8c00 100%);
  box-shadow: 0 2px 8px rgba(255, 193, 7, 0.3);
}

.btn-modal-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.btn-modal-info:hover {
  background: linear-gradient(135deg, #138496 0%, #117a8b 100%);
  box-shadow: 0 2px 8px rgba(23, 162, 184, 0.3);
}

.btn-modal-secondary {
  background: #6c757d;
  color: white;
}

.btn-modal-secondary:hover {
  background: #5a6268;
  box-shadow: 0 2px 8px rgba(108, 117, 125, 0.3);
}

/* Transiciones */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .modal-container,
.modal-leave-active .modal-container {
  transition: transform 0.3s;
}

.modal-enter-from .modal-container,
.modal-leave-to .modal-container {
  transform: scale(0.9);
}
</style>

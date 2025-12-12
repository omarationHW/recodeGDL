<template>
  <teleport to="body">
    <div v-if="show" class="municipal-modal-overlay" @click.self="handleClose">
      <div class="municipal-modal">
        <div class="municipal-modal-header" :class="typeClass">
          <h5 class="municipal-modal-title">{{ title }}</h5>
          <button class="municipal-modal-close" @click="handleClose">
            &times;
          </button>
        </div>
        <div class="municipal-modal-body">
          <p>{{ message }}</p>
        </div>
        <div class="municipal-modal-footer">
          <button class="btn-municipal-primary" @click="handleConfirm">
            Aceptar
          </button>
        </div>
      </div>
    </div>
  </teleport>
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
    default: ''
  },
  message: {
    type: String,
    default: ''
  },
  type: {
    type: String,
    default: 'success',
    validator: (v) => ['success', 'error', 'warning', 'info'].includes(v)
  }
})

const emit = defineEmits(['close', 'confirm'])

const typeClass = computed(() => `modal-type-${props.type}`)

function handleClose() {
  emit('close')
}

function handleConfirm() {
  emit('confirm')
}
</script>

<style scoped>
.municipal-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 10000;
}

.municipal-modal {
  background: white;
  border-radius: 8px;
  min-width: 350px;
  max-width: 500px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.municipal-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid #e0e0e0;
  border-radius: 8px 8px 0 0;
}

.municipal-modal-header.modal-type-success {
  background: #28a745;
  color: white;
}

.municipal-modal-header.modal-type-error {
  background: #dc3545;
  color: white;
}

.municipal-modal-header.modal-type-warning {
  background: #ffc107;
  color: #212529;
}

.municipal-modal-header.modal-type-info {
  background: #17a2b8;
  color: white;
}

.municipal-modal-title {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.municipal-modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: inherit;
  opacity: 0.8;
}

.municipal-modal-close:hover {
  opacity: 1;
}

.municipal-modal-body {
  padding: 20px;
}

.municipal-modal-body p {
  margin: 0;
  color: #333;
}

.municipal-modal-footer {
  padding: 15px 20px;
  border-top: 1px solid #e0e0e0;
  display: flex;
  justify-content: flex-end;
}

.btn-municipal-primary {
  background: #4a6da7;
  color: white;
  border: none;
  padding: 8px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}

.btn-municipal-primary:hover {
  background: #3a5a87;
}
</style>

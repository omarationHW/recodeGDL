<template>
  <teleport to="body">
    <div
      v-if="show"
      class="modal fade show d-block"
      :class="{ 'modal-backdrop-show': show }"
      tabindex="-1"
      @click.self="closeModal"
    >
      <div class="modal-dialog" :class="sizeClass">
        <div class="modal-content">
          <div class="modal-header" v-if="title || $slots.header">
            <slot name="header">
              <h5 class="modal-title">{{ title }}</h5>
            </slot>
            <button
              type="button"
              class="btn-close"
              @click="closeModal"
              :disabled="!closable"
            ></button>
          </div>
          
          <div class="modal-body">
            <slot></slot>
          </div>
          
          <div class="modal-footer" v-if="$slots.footer || showDefaultFooter">
            <slot name="footer">
              <button
                v-if="showCancelButton"
                type="button"
                class="btn btn-secondary"
                @click="closeModal"
                :disabled="loading"
              >
                {{ cancelText }}
              </button>
              <button
                v-if="showConfirmButton"
                type="button"
                class="btn"
                :class="confirmButtonClass"
                @click="confirmAction"
                :disabled="loading"
              >
                <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                {{ confirmText }}
              </button>
            </slot>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Backdrop -->
    <div
      v-if="show"
      class="modal-backdrop fade show"
      @click="closeModal"
    ></div>
  </teleport>
</template>

<script>
export default {
  name: 'Modal',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    title: {
      type: String,
      default: ''
    },
    size: {
      type: String,
      default: 'md', // sm, md, lg, xl
      validator: (value) => ['sm', 'md', 'lg', 'xl'].includes(value)
    },
    closable: {
      type: Boolean,
      default: true
    },
    showDefaultFooter: {
      type: Boolean,
      default: false
    },
    showCancelButton: {
      type: Boolean,
      default: true
    },
    showConfirmButton: {
      type: Boolean,
      default: true
    },
    cancelText: {
      type: String,
      default: 'Cancelar'
    },
    confirmText: {
      type: String,
      default: 'Aceptar'
    },
    confirmButtonClass: {
      type: String,
      default: 'btn-primary'
    },
    loading: {
      type: Boolean,
      default: false
    },
    persistent: {
      type: Boolean,
      default: false
    }
  },
  emits: ['close', 'confirm', 'update:show'],
  computed: {
    sizeClass() {
      const sizeMap = {
        sm: 'modal-sm',
        md: '',
        lg: 'modal-lg',
        xl: 'modal-xl'
      }
      return sizeMap[this.size] || ''
    }
  },
  watch: {
    show(newVal) {
      if (newVal) {
        document.body.classList.add('modal-open')
        this.addEscapeListener()
      } else {
        document.body.classList.remove('modal-open')
        this.removeEscapeListener()
      }
    }
  },
  mounted() {
    if (this.show) {
      document.body.classList.add('modal-open')
      this.addEscapeListener()
    }
  },
  beforeUnmount() {
    document.body.classList.remove('modal-open')
    this.removeEscapeListener()
  },
  methods: {
    closeModal() {
      if (!this.closable || this.persistent) return
      
      this.$emit('close')
      this.$emit('update:show', false)
    },
    confirmAction() {
      this.$emit('confirm')
    },
    handleEscape(event) {
      if (event.key === 'Escape' && this.show && this.closable && !this.persistent) {
        this.closeModal()
      }
    },
    addEscapeListener() {
      document.addEventListener('keydown', this.handleEscape)
    },
    removeEscapeListener() {
      document.removeEventListener('keydown', this.handleEscape)
    }
  }
}
</script>

<style scoped>
.modal {
  background-color: rgba(0, 0, 0, 0.5);
}

.modal-backdrop {
  background-color: rgba(0, 0, 0, 0.5);
}

.modal-dialog {
  margin: 1.75rem auto;
  max-width: 500px;
}

.modal-sm {
  max-width: 300px;
}

.modal-lg {
  max-width: 800px;
}

.modal-xl {
  max-width: 1140px;
}

.modal-content {
  border: none;
  border-radius: 8px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.modal-header {
  border-bottom: 1px solid #dee2e6;
  padding: 1rem 1.5rem;
  background-color: #f8f9fa;
  border-radius: 8px 8px 0 0;
}

.modal-title {
  font-weight: 600;
  color: #333;
  margin: 0;
}

.modal-body {
  padding: 1.5rem;
  max-height: 70vh;
  overflow-y: auto;
}

.modal-footer {
  border-top: 1px solid #dee2e6;
  padding: 1rem 1.5rem;
  background-color: #f8f9fa;
  border-radius: 0 0 8px 8px;
}

.btn-close {
  background: none;
  border: none;
  font-size: 1.25rem;
  font-weight: bold;
  color: #aaa;
  opacity: 0.5;
  cursor: pointer;
}

.btn-close:hover {
  opacity: 0.75;
}

.spinner-border-sm {
  width: 1rem;
  height: 1rem;
}

/* Animaciones */
.modal.fade.show {
  animation: modalFadeIn 0.3s ease;
}

.modal-backdrop.fade.show {
  animation: backdropFadeIn 0.3s ease;
}

@keyframes modalFadeIn {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes backdropFadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}
</style>
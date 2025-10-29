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
      console.log('🔘 Modal: confirmAction disparado')
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


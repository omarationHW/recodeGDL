<template>
  <div 
    v-if="message" 
    :class="['alert', isError ? 'alert-error' : 'alert-success']"
  >
    {{ message }}
  </div>
</template>

<script>
export default {
  name: 'AlertMessage',
  props: {
    message: {
      type: String,
      default: ''
    },
    isError: {
      type: Boolean,
      default: false
    }
  }
}
</script>
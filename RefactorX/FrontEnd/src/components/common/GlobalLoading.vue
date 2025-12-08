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

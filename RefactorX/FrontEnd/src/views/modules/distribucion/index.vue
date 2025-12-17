<template>
  <div class="module-container">
    <h1>Módulo Distribución</h1>
    <p>Accediendo al sistema...</p>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

onMounted(() => {
  // Redirigir automáticamente a la página de acceso
  router.push('/distribucion/acceso')
})
</script>

<style scoped>
.module-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background: var(--gradient-guadalajara);
  color: white;
}

h1 {
  font-size: 2rem;
  margin-bottom: 1rem;
}

p {
  font-size: 1.2rem;
}
</style>

<template>
  <div class="module-view module-layout"><div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="lock" /></div><div class="module-view-info"><h1>Acceso</h1></div></div>
    <div class="module-view-content"><div class="municipal-card"><div class="municipal-card-body">
      <div class="form-row"><div class="form-group"><label class="municipal-form-label">Usuario</label><input class="municipal-form-control" v-model="user"/></div><div class="form-group"><label class="municipal-form-label">Password</label><input class="municipal-form-control" v-model="pass" type="password"/></div></div>
      <div class="button-group"><button class="btn-municipal-primary">Entrar</button></div>
    </div></div></div>
  </div>
</template>
<script setup>
import { ref } from 'vue'; const user=ref(''); const pass=ref('')
</script>


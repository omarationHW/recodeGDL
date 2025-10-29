<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="key" /></div>
      <div class="module-view-info">
        <h1>Usuarios/Passwords — Estacionamientos</h1>
        <p>Consulta y actualización de usuarios</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="load"><font-awesome-icon icon="sync-alt" /> Actualizar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Usuario (filtro)</label><input class="municipal-form-control" v-model="filtroUsuario" placeholder="Opcional" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Usuarios</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>ID</th><th>Usuario</th><th>Nombre</th><th>Estado</th><th>Reca</th><th>Nivel</th><th>Acciones</th></tr></thead>
              <tbody>
                <tr v-for="u in usuarios" :key="u.id_usuario">
                  <td>{{ u.id_usuario }}</td>
                  <td>{{ u.usuario }}</td>
                  <td><input class="municipal-form-control" v-model="u.nombre" /></td>
                  <td><input class="municipal-form-control" v-model="u.estado" maxlength="1" /></td>
                  <td><input class="municipal-form-control" type="number" v-model.number="u.id_rec" /></td>
                  <td><input class="municipal-form-control" type="number" v-model.number="u.nivel" /></td>
                  <td><button class="btn-municipal-primary btn-sm" @click="update(u)"><font-awesome-icon icon="save" /></button></td>
                </tr>
                <tr v-if="usuarios.length===0"><td colspan="7" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const filtroUsuario = ref('')
const usuarios = ref([])
const loading = ref(false)

async function load() {
  loading.value = true
  usuarios.value = []
  try {
    const params = [ { nombre: 'p_usuario', valor: filtroUsuario.value || null, tipo: 'string' } ]
    const resp = await apiService.execute('sp_passwords_list', 'estacionamiento_publico', params)
    usuarios.value = resp?.data?.result || []
  } catch (e) {
    usuarios.value = []
  } finally {
    loading.value = false
  }
}

async function update(u) {
  try {
    const params = [
      { nombre: 'p_id_usuario', valor: u.id_usuario, tipo: 'integer' },
      { nombre: 'p_usuario', valor: u.usuario, tipo: 'string' },
      { nombre: 'p_nombre', valor: u.nombre, tipo: 'string' },
      { nombre: 'p_estado', valor: u.estado, tipo: 'string' },
      { nombre: 'p_id_rec', valor: u.id_rec, tipo: 'integer' },
      { nombre: 'p_nivel', valor: u.nivel, tipo: 'integer' }
    ]
    await apiService.execute('sp_passwords_update', 'estacionamiento_publico', params)
  } catch (e) {
    // noop
  }
}

load()
</script>


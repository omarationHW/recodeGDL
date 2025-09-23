<template>
  <div class="page-container">
    <h1>Mantenimiento de Recaudadoras</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Recaudadoras
    </div>
    <div v-if="mode==='list'">
      <button @click="setMode('create')">Nueva Recaudadora</button>
      <table class="table">
        <thead>
          <tr>
            <th>No. Recaudadora</th>
            <th>Descripción</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="rec in recaudadoras" :key="rec.num_rec">
            <td>{{ rec.num_rec }}</td>
            <td>{{ rec.descripcion }}</td>
            <td>
              <button @click="editRec(rec)">Editar</button>
              <button @click="deleteRec(rec)">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div v-if="error" class="error">{{ error }}</div>
      <div v-if="success" class="success">{{ success }}</div>
    </div>
    <div v-else>
      <form @submit.prevent="submitForm">
        <div>
          <label>No. Recaudadora</label>
          <input v-model.number="form.num_rec" :disabled="mode==='update'" required type="number" min="1" max="9999" />
        </div>
        <div>
          <label>Descripción</label>
          <input v-model="form.descripcion" required maxlength="80" />
        </div>
        <div class="form-actions">
          <button type="submit">{{ mode==='create' ? 'Crear' : 'Actualizar' }}</button>
          <button type="button" @click="setMode('list')">Cancelar</button>
        </div>
        <div v-if="error" class="error">{{ error }}</div>
        <div v-if="success" class="success">{{ success }}</div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ManntoRecaudadoras',
  data() {
    return {
      recaudadoras: [],
      mode: 'list', // list | create | update
      form: {
        num_rec: '',
        descripcion: ''
      },
      error: '',
      success: ''
    }
  },
  mounted() {
    this.fetchList();
  },
  methods: {
    setMode(mode) {
      this.mode = mode;
      this.error = '';
      this.success = '';
      if (mode === 'create') {
        this.form = { num_rec: '', descripcion: '' };
      }
    },
    fetchList() {
      this.error = '';
      this.success = '';
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'list' })
      })
        .then(res => res.json())
        .then(res => {
          if (res.success) {
            this.recaudadoras = res.data;
          } else {
            this.error = res.message;
          }
        })
        .catch(e => { this.error = e.message });
    },
    submitForm() {
      this.error = '';
      this.success = '';
      const action = this.mode === 'create' ? 'create' : 'update';
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, payload: this.form })
      })
        .then(res => res.json())
        .then(res => {
          if (res.success) {
            this.success = res.message;
            this.fetchList();
            this.setMode('list');
          } else {
            this.error = res.message;
          }
        })
        .catch(e => { this.error = e.message });
    },
    editRec(rec) {
      this.form = { ...rec };
      this.mode = 'update';
      this.error = '';
      this.success = '';
    },
    deleteRec(rec) {
      if (!confirm('¿Está seguro de eliminar la recaudadora?')) return;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'delete', payload: { num_rec: rec.num_rec } })
      })
        .then(res => res.json())
        .then(res => {
          if (res.success) {
            this.success = res.message;
            this.fetchList();
          } else {
            this.error = res.message;
          }
        })
        .catch(e => { this.error = e.message });
    }
  }
}
</script>

<style scoped>
.page-container { max-width: 700px; margin: 0 auto; padding: 2rem; }
.breadcrumb { margin-bottom: 1rem; font-size: 0.9rem; color: #888; }
.table { width: 100%; border-collapse: collapse; margin-bottom: 1rem; }
.table th, .table td { border: 1px solid #ccc; padding: 0.5rem; }
.form-actions { margin-top: 1rem; }
.error { color: #b00; margin-top: 1rem; }
.success { color: #080; margin-top: 1rem; }
</style>

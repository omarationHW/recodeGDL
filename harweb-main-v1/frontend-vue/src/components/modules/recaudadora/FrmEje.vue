<template>
  <div class="frm-eje-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Ejecutores</span>
    </nav>
    <h1>Catálogo de Ejecutores</h1>
    <div class="actions">
      <button @click="showCreateForm = true">Nuevo Ejecutor</button>
      <button @click="fetchReport">Reporte</button>
    </div>
    <div v-if="showCreateForm">
      <h2>Nuevo Ejecutor</h2>
      <form @submit.prevent="createEjecutor">
        <label>Apellido Paterno: <input v-model="form.paterno" required /></label>
        <label>Apellido Materno: <input v-model="form.materno" required /></label>
        <label>Nombres: <input v-model="form.nombres" required /></label>
        <label>RFC: <input v-model="form.rfc" required /></label>
        <label>Recaudadora: <input v-model.number="form.recaud" required type="number" min="1" /></label>
        <label>Oficio: <input v-model="form.oficio" required /></label>
        <label>Fecha Ingreso: <input v-model="form.fecing" type="date" required /></label>
        <label>Fecha Inicio: <input v-model="form.fecinic" type="date" required /></label>
        <label>Fecha Término: <input v-model="form.fecterm" type="date" required /></label>
        <button type="submit">Guardar</button>
        <button type="button" @click="showCreateForm = false">Cancelar</button>
      </form>
    </div>
    <div v-if="showEditForm">
      <h2>Editar Ejecutor</h2>
      <form @submit.prevent="updateEjecutor">
        <label>Apellido Paterno: <input v-model="form.paterno" required /></label>
        <label>Apellido Materno: <input v-model="form.materno" required /></label>
        <label>Nombres: <input v-model="form.nombres" required /></label>
        <label>RFC: <input v-model="form.rfc" required /></label>
        <label>Recaudadora: <input v-model.number="form.recaud" required type="number" min="1" /></label>
        <label>Oficio: <input v-model="form.oficio" required /></label>
        <label>Fecha Ingreso: <input v-model="form.fecing" type="date" required /></label>
        <label>Fecha Inicio: <input v-model="form.fecinic" type="date" required /></label>
        <label>Fecha Término: <input v-model="form.fecterm" type="date" required /></label>
        <button type="submit">Actualizar</button>
        <button type="button" @click="showEditForm = false">Cancelar</button>
      </form>
    </div>
    <table class="ejecutores-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Paterno</th>
          <th>Materno</th>
          <th>Nombres</th>
          <th>RFC</th>
          <th>Recaudadora</th>
          <th>Oficio</th>
          <th>Fecha Ingreso</th>
          <th>Fecha Inicio</th>
          <th>Fecha Término</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="e in ejecutores" :key="e.cveejecutor">
          <td>{{ e.cveejecutor }}</td>
          <td>{{ e.paterno }}</td>
          <td>{{ e.materno }}</td>
          <td>{{ e.nombres }}</td>
          <td>{{ e.rfc }}</td>
          <td>{{ e.recaud }}</td>
          <td>{{ e.oficio }}</td>
          <td>{{ e.fecing }}</td>
          <td>{{ e.fecinic }}</td>
          <td>{{ e.fecterm }}</td>
          <td>
            <button @click="editEjecutor(e)">Editar</button>
            <button @click="deleteEjecutor(e.cveejecutor)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="reportData.length">
      <h2>Reporte de Ejecutores</h2>
      <table class="report-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Paterno</th>
            <th>Materno</th>
            <th>Nombres</th>
            <th>RFC</th>
            <th>Recaudadora</th>
            <th>Oficio</th>
            <th>Fecha Ingreso</th>
            <th>Fecha Inicio</th>
            <th>Fecha Término</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in reportData" :key="r.cveejecutor">
            <td>{{ r.cveejecutor }}</td>
            <td>{{ r.paterno }}</td>
            <td>{{ r.materno }}</td>
            <td>{{ r.nombres }}</td>
            <td>{{ r.rfc }}</td>
            <td>{{ r.recaud }}</td>
            <td>{{ r.oficio }}</td>
            <td>{{ r.fecing }}</td>
            <td>{{ r.fecinic }}</td>
            <td>{{ r.fecterm }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'FrmEjePage',
  data() {
    return {
      ejecutores: [],
      reportData: [],
      error: '',
      showCreateForm: false,
      showEditForm: false,
      form: {
        cveejecutor: null,
        paterno: '',
        materno: '',
        nombres: '',
        rfc: '',
        recaud: '',
        oficio: '',
        fecing: '',
        fecinic: '',
        fecterm: ''
      }
    };
  },
  created() {
    this.fetchEjecutores();
  },
  methods: {
    async fetchEjecutores() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.listEjecutores',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.ejecutores = res.data.data;
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    },
    async createEjecutor() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.createEjecutor',
          payload: this.form
        });
        if (res.data.status === 'success') {
          this.showCreateForm = false;
          this.fetchEjecutores();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    },
    editEjecutor(e) {
      this.form = { ...e };
      this.showEditForm = true;
    },
    async updateEjecutor() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.updateEjecutor',
          payload: this.form
        });
        if (res.data.status === 'success') {
          this.showEditForm = false;
          this.fetchEjecutores();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    },
    async deleteEjecutor(id) {
      if (!confirm('¿Está seguro de eliminar este ejecutor?')) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.deleteEjecutor',
          payload: { cveejecutor: id }
        });
        if (res.data.status === 'success') {
          this.fetchEjecutores();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    },
    async fetchReport() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.reportEjecutores',
          payload: { fecha_inicio: '', fecha_fin: '', recaud: '' }
        });
        if (res.data.status === 'success') {
          this.reportData = res.data.data;
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    }
  }
};
</script>

<style scoped>
.frm-eje-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.actions {
  margin-bottom: 1rem;
}
.ejecutores-table, .report-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 2rem;
}
.ejecutores-table th, .ejecutores-table td, .report-table th, .report-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
</style>

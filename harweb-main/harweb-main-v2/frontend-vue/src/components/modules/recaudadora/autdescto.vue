<template>
  <div class="autdescto-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Autorización de Descuentos Predial</span>
    </nav>
    <h1>Autorización de Descuentos Predial</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label>Cve. Cuenta *</label>
        <input v-model="form.cvecuenta" type="number" required />
      </div>
      <div class="form-row">
        <label>Tipo de Descuento *</label>
        <select v-model="form.cvedescuento" required>
          <option v-for="d in catalogs.descTypes" :key="d.cvedescuento" :value="d.cvedescuento">
            {{ d.axodescto }} - {{ d.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Bimestre Inicial *</label>
        <input v-model="form.bimini" type="number" min="1" max="6" required />
      </div>
      <div class="form-row">
        <label>Bimestre Final *</label>
        <input v-model="form.bimfin" type="number" min="1" max="6" required />
      </div>
      <div class="form-row">
        <label>Solicitante *</label>
        <input v-model="form.solicitante" type="text" maxlength="40" required />
      </div>
      <div class="form-row">
        <label>Observaciones</label>
        <textarea v-model="form.observaciones" maxlength="255"></textarea>
      </div>
      <div class="form-row">
        <label>Institución</label>
        <select v-model="form.institucion">
          <option value="">-- Seleccione --</option>
          <option v-for="i in catalogs.institutions" :key="i.cveinst" :value="i.cveinst">
            {{ i.institucion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Identificación</label>
        <input v-model="form.identificacion" type="text" maxlength="40" />
      </div>
      <div class="form-row">
        <label>Fecha de Nacimiento</label>
        <input v-model="form.fecnac" type="date" />
      </div>
      <div class="form-actions">
        <button type="submit" :disabled="loading">Guardar</button>
        <button type="button" @click="resetForm">Limpiar</button>
      </div>
    </form>
    <hr />
    <h2>Descuentos Registrados</h2>
    <table class="table">
      <thead>
        <tr>
          <th>Cuenta</th>
          <th>Tipo</th>
          <th>Bim. Ini</th>
          <th>Bim. Fin</th>
          <th>Solicitante</th>
          <th>Institución</th>
          <th>Identificación</th>
          <th>Alta</th>
          <th>Baja</th>
          <th>Estatus</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="d in descuentos" :key="d.id">
          <td>{{ d.cvecuenta }}</td>
          <td>{{ d.descripcion }}</td>
          <td>{{ d.bimini }}</td>
          <td>{{ d.bimfin }}</td>
          <td>{{ d.solicitante }}</td>
          <td>{{ d.institucion_nombre }}</td>
          <td>{{ d.identificacion }}</td>
          <td>{{ d.fecalta | fecha }}</td>
          <td>{{ d.fecbaja ? (d.fecbaja | fecha) : '' }}</td>
          <td>
            <span v-if="d.status === 'C'" class="badge badge-danger">Cancelado</span>
            <span v-else class="badge badge-success">Vigente</span>
          </td>
          <td>
            <button @click="editDescuento(d)" :disabled="d.status==='C'">Editar</button>
            <button @click="cancelDescuento(d)" :disabled="d.status==='C'">Cancelar</button>
            <button @click="reactivateDescuento(d)" v-if="d.status==='C'">Reactivar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="success" class="alert alert-success">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'AutDesctoPage',
  data() {
    return {
      form: {
        cvecuenta: '',
        cvedescuento: '',
        bimini: '',
        bimfin: '',
        solicitante: '',
        observaciones: '',
        institucion: '',
        identificacion: '',
        fecnac: ''
      },
      descuentos: [],
      catalogs: {
        descTypes: [],
        institutions: []
      },
      loading: false,
      error: '',
      success: ''
    }
  },
  filters: {
    fecha(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    }
  },
  created() {
    this.fetchCatalogs();
    this.fetchDescuentos();
  },
  methods: {
    async fetchCatalogs() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'catalogs',
          params: {}
        });
        if (res.data.status === 'ok') {
          this.catalogs = res.data.data;
        }
      } catch (e) {
        this.error = 'Error cargando catálogos';
      }
    },
    async fetchDescuentos() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'list',
          params: { cvecuenta: this.form.cvecuenta }
        });
        if (res.data.status === 'ok') {
          this.descuentos = res.data.data.map(d => ({
            ...d,
            institucion_nombre: this.catalogs.institutions.find(i => i.cveinst == d.institucion)?.institucion || ''
          }));
        }
      } catch (e) {
        this.error = 'Error cargando descuentos';
      } finally {
        this.loading = false;
      }
    },
    async onSubmit() {
      this.loading = true;
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: this.form.id ? 'update' : 'create',
          params: this.form
        });
        if (res.data.status === 'ok') {
          this.success = res.data.message;
          this.fetchDescuentos();
          this.resetForm();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error al guardar';
      } finally {
        this.loading = false;
      }
    },
    editDescuento(d) {
      this.form = { ...d };
    },
    async cancelDescuento(d) {
      if (!confirm('¿Cancelar este descuento?')) return;
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'cancel',
          params: { id: d.id }
        });
        if (res.data.status === 'ok') {
          this.success = res.data.message;
          this.fetchDescuentos();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error al cancelar';
      } finally {
        this.loading = false;
      }
    },
    async reactivateDescuento(d) {
      if (!confirm('¿Reactivar este descuento?')) return;
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'reactivate',
          params: { id: d.id }
        });
        if (res.data.status === 'ok') {
          this.success = res.data.message;
          this.fetchDescuentos();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error al reactivar';
      } finally {
        this.loading = false;
      }
    },
    resetForm() {
      this.form = {
        cvecuenta: '',
        cvedescuento: '',
        bimini: '',
        bimfin: '',
        solicitante: '',
        observaciones: '',
        institucion: '',
        identificacion: '',
        fecnac: ''
      };
      this.error = '';
      this.success = '';
    }
  }
}
</script>

<style scoped>
.autdescto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  flex-direction: column;
}
.form-actions {
  margin-top: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.badge {
  padding: 0.2em 0.5em;
  border-radius: 0.3em;
}
.badge-danger {
  background: #e74c3c;
  color: #fff;
}
.badge-success {
  background: #27ae60;
  color: #fff;
}
.alert {
  margin-top: 1rem;
  padding: 1rem;
  border-radius: 0.3em;
}
.alert-danger {
  background: #f8d7da;
  color: #721c24;
}
.alert-success {
  background: #d4edda;
  color: #155724;
}
</style>

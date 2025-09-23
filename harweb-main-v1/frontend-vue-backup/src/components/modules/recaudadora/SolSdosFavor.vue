<template>
  <div class="sol-sdos-favor-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Solicitud de Saldos a Favor</span>
    </nav>
    <h1>Solicitud de Saldos a Favor</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label>Folio:</label>
        <input v-model="form.folio" type="text" disabled />
        <label>Status:</label>
        <span :class="statusClass">{{ statusLabel }}</span>
      </div>
      <div class="form-row">
        <label>Propietario:</label>
        <input v-model="form.ncompleto" type="text" disabled />
      </div>
      <div class="form-row">
        <label>Calle:</label>
        <input v-model="form.domp" type="text" required />
        <label>No. Ext.:</label>
        <input v-model="form.extp" type="text" required />
        <label>No. Int.:</label>
        <input v-model="form.intp" type="text" />
      </div>
      <div class="form-row">
        <label>Colonia:</label>
        <input v-model="form.colp" type="text" required />
        <label>Teléfono:</label>
        <input v-model="form.telefono" type="text" />
        <label>C.P.:</label>
        <input v-model="form.codp" type="text" />
      </div>
      <div class="form-row">
        <label>Solicitante:</label>
        <input v-model="form.solicitante" type="text" required />
      </div>
      <div class="form-row">
        <label>Documentación Entregada:</label>
        <div class="checkbox-group">
          <label v-for="doc in doctosCatalog" :key="doc.id">
            <input type="checkbox" :value="doc.id" v-model="form.doctos" /> {{ doc.nombre }}
          </label>
        </div>
      </div>
      <div class="form-row">
        <label>Observaciones:</label>
        <textarea v-model="form.observaciones"></textarea>
      </div>
      <div class="form-row">
        <label>Inconformidad:</label>
        <select v-model="form.inconf">
          <option v-for="inc in inconformidadesCatalog" :key="inc.id" :value="inc.id">{{ inc.nombre }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Peticionario:</label>
        <select v-model="form.peticionario">
          <option v-for="pet in peticionariosCatalog" :key="pet.id" :value="pet.id">{{ pet.nombre }}</option>
        </select>
      </div>
      <div class="form-actions">
        <button type="submit" :disabled="loading">{{ isEdit ? 'Actualizar' : 'Guardar' }}</button>
        <button type="button" @click="onCancel" v-if="isEdit">Cancelar</button>
        <button type="button" @click="onNew">Nuevo</button>
      </div>
    </form>
    <div class="solicitudes-list">
      <h2>Solicitudes Recientes</h2>
      <table>
        <thead>
          <tr>
            <th>Folio</th>
            <th>Propietario</th>
            <th>Status</th>
            <th>Fecha</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="sol in solicitudes" :key="sol.id_solic">
            <td>{{ sol.folio }}</td>
            <td>{{ sol.ncompleto }}</td>
            <td>{{ statusLabelFromCode(sol.status) }}</td>
            <td>{{ sol.feccap | formatDate }}</td>
            <td>
              <button @click="onEdit(sol)">Editar</button>
              <button @click="onCancelSolicitud(sol)" v-if="sol.status === 'P'">Cancelar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'SolSdosFavorPage',
  data() {
    return {
      form: {
        id_solic: null,
        folio: '',
        ncompleto: '',
        cvecuenta: '',
        domp: '',
        extp: '',
        intp: '',
        colp: '',
        telefono: '',
        codp: '',
        solicitante: '',
        observaciones: '',
        doctos: [],
        status: 'P',
        inconf: '',
        peticionario: ''
      },
      solicitudes: [],
      doctosCatalog: [],
      inconformidadesCatalog: [],
      peticionariosCatalog: [],
      loading: false,
      error: '',
      isEdit: false
    };
  },
  computed: {
    statusLabel() {
      switch (this.form.status) {
        case 'P': return 'PENDIENTE';
        case 'C': return 'CANCELADO';
        case 'T': return 'TERMINADO';
        case 'A': return 'APLICADO';
        default: return this.form.status;
      }
    },
    statusClass() {
      return {
        'status-pendiente': this.form.status === 'P',
        'status-cancelado': this.form.status === 'C',
        'status-terminado': this.form.status === 'T',
        'status-aplicado': this.form.status === 'A'
      };
    }
  },
  filters: {
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    }
  },
  methods: {
    async fetchCatalogs() {
      try {
        const [doctos, inconfs, pets] = await Promise.all([
          axios.post('/api/execute', { action: 'getDoctosCatalog' }),
          axios.post('/api/execute', { action: 'getInconformidadesCatalog' }),
          axios.post('/api/execute', { action: 'getPeticionariosCatalog' })
        ]);
        this.doctosCatalog = doctos.data.data;
        this.inconformidadesCatalog = inconfs.data.data;
        this.peticionariosCatalog = pets.data.data;
      } catch (e) {
        this.error = 'Error cargando catálogos';
      }
    },
    async fetchSolicitudes() {
      try {
        const res = await axios.post('/api/execute', { action: 'listSolicitudes' });
        this.solicitudes = res.data.data;
      } catch (e) {
        this.error = 'Error cargando solicitudes';
      }
    },
    async onSubmit() {
      this.loading = true;
      this.error = '';
      try {
        let action = this.isEdit ? 'updateSolicitud' : 'createSolicitud';
        let params = { ...this.form };
        // Convert doctos array to string if needed
        if (Array.isArray(params.doctos)) params.doctos = params.doctos.join(',');
        const res = await axios.post('/api/execute', { action, params });
        if (res.data.success) {
          this.fetchSolicitudes();
          this.onNew();
        } else {
          this.error = res.data.message || 'Error al guardar';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    onNew() {
      this.form = {
        id_solic: null,
        folio: '',
        ncompleto: '',
        cvecuenta: '',
        domp: '',
        extp: '',
        intp: '',
        colp: '',
        telefono: '',
        codp: '',
        solicitante: '',
        observaciones: '',
        doctos: [],
        status: 'P',
        inconf: '',
        peticionario: ''
      };
      this.isEdit = false;
    },
    onEdit(sol) {
      this.form = { ...sol, doctos: sol.doctos ? sol.doctos.split(',') : [] };
      this.isEdit = true;
    },
    async onCancelSolicitud(sol) {
      if (!confirm('¿Cancelar esta solicitud?')) return;
      try {
        const res = await axios.post('/api/execute', { action: 'cancelSolicitud', params: { id_solic: sol.id_solic } });
        if (res.data.success) {
          this.fetchSolicitudes();
        } else {
          this.error = res.data.message || 'Error al cancelar';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    statusLabelFromCode(code) {
      switch (code) {
        case 'P': return 'PENDIENTE';
        case 'C': return 'CANCELADO';
        case 'T': return 'TERMINADO';
        case 'A': return 'APLICADO';
        default: return code;
      }
    },
    onCancel() {
      this.onNew();
    }
  },
  mounted() {
    this.fetchCatalogs();
    this.fetchSolicitudes();
  }
};
</script>

<style scoped>
.sol-sdos-favor-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.form-row {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}
.form-row label {
  width: 140px;
  font-weight: bold;
}
.form-row input, .form-row select, .form-row textarea {
  flex: 1;
  margin-right: 1rem;
}
.checkbox-group {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}
.status-pendiente { color: orange; }
.status-cancelado { color: red; }
.status-terminado { color: green; }
.status-aplicado { color: blue; }
.solicitudes-list {
  margin-top: 2rem;
}
.solicitudes-list table {
  width: 100%;
  border-collapse: collapse;
}
.solicitudes-list th, .solicitudes-list td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.error { color: red; margin-top: 1rem; }
</style>

<template>
  <div class="auttranspatr-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/tramites">Trámites</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Autorización Transmisión Patrimonial</li>
      </ol>
    </nav>
    <h2>Autorización de Transmisión Patrimonial</h2>
    <form @submit.prevent="onSubmit">
      <div class="form-group">
        <label for="folio">Folio</label>
        <input v-model="form.folio" id="folio" type="number" class="form-control" required :readonly="!!form.status" />
      </div>
      <div class="form-group">
        <label>
          <input type="checkbox" v-model="form.exento" true-value="S" false-value="N" :disabled="form.status === 'P'" />
          Causa Impuesto
        </label>
      </div>
      <div class="form-group">
        <label for="tasa_preferencial">Tasa Preferencial</label>
        <select v-model="form.tasa_preferencial" id="tasa_preferencial" class="form-control" :disabled="form.status === 'P'">
          <option value="N">No</option>
          <option value="S">Sí</option>
        </select>
      </div>
      <div class="form-group">
        <label for="documentos_otros">Justificación Legal</label>
        <textarea v-model="form.documentos_otros" id="documentos_otros" class="form-control" rows="4" required :readonly="form.status === 'P'"></textarea>
      </div>
      <div class="form-group">
        <label for="justificacion">Observaciones</label>
        <textarea v-model="form.justificacion" id="justificacion" class="form-control" rows="2" :readonly="form.status === 'P'"></textarea>
      </div>
      <div class="form-group mt-3">
        <button type="submit" class="btn btn-primary" :disabled="loading || form.status === 'P'">Guardar</button>
        <button type="button" class="btn btn-success ml-2" @click="onAuthorize" :disabled="loading || form.status === 'P'">Autorizar</button>
        <button type="button" class="btn btn-secondary ml-2" @click="onClose" :disabled="loading || form.status !== 'A'">Cerrar</button>
        <button type="button" class="btn btn-warning ml-2" @click="onReopen" :disabled="loading || form.status !== 'C'">Reabrir</button>
      </div>
      <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
    </form>
    <div class="mt-5">
      <h4>Historial de Autorizaciones</h4>
      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Exento</th>
            <th>Tasa Preferencial</th>
            <th>Justificación</th>
            <th>Status</th>
            <th>Usuario</th>
            <th>Fecha</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in history" :key="row.folio">
            <td>{{ row.folio }}</td>
            <td>{{ row.exento }}</td>
            <td>{{ row.tasa_preferencial }}</td>
            <td>{{ row.documentos_otros }}</td>
            <td>{{ row.status }}</td>
            <td>{{ row.usuario }}</td>
            <td>{{ row.fecha | formatDate }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'AutTransPatrimonialPage',
  data() {
    return {
      form: {
        folio: '',
        exento: 'N',
        documentos_otros: '',
        justificacion: '',
        tasa_preferencial: 'N',
        usuario: ''
      },
      loading: false,
      message: '',
      success: true,
      history: []
    };
  },
  created() {
    this.form.usuario = this.$store.state.user.username || '';
    if (this.$route.params.folio) {
      this.form.folio = this.$route.params.folio;
      this.fetchData();
    }
    this.fetchHistory();
  },
  methods: {
    async fetchData() {
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            action: 'get',
            data: { folio: this.form.folio }
          }
        });
        if (res.data.eResponse.success && res.data.eResponse.data) {
          Object.assign(this.form, res.data.eResponse.data);
        }
      } catch (e) {
        this.message = e.response?.data?.eResponse?.message || 'Error al cargar datos';
        this.success = false;
      } finally {
        this.loading = false;
      }
    },
    async fetchHistory() {
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            action: 'list',
            data: { filters: { } }
          }
        });
        if (res.data.eResponse.success) {
          this.history = res.data.eResponse.data;
        }
      } catch (e) {
        // silent
      }
    },
    async onSubmit() {
      this.loading = true;
      this.message = '';
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            action: 'save',
            data: { ...this.form }
          }
        });
        this.success = res.data.eResponse.success;
        this.message = res.data.eResponse.message;
        if (this.success) {
          this.fetchHistory();
        }
      } catch (e) {
        this.success = false;
        this.message = e.response?.data?.eResponse?.message || 'Error al guardar';
      } finally {
        this.loading = false;
      }
    },
    async onAuthorize() {
      this.loading = true;
      this.message = '';
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            action: 'authorize',
            data: { folio: this.form.folio, usuario: this.form.usuario }
          }
        });
        this.success = res.data.eResponse.success;
        this.message = res.data.eResponse.message;
        if (this.success) {
          this.fetchData();
          this.fetchHistory();
        }
      } catch (e) {
        this.success = false;
        this.message = e.response?.data?.eResponse?.message || 'Error al autorizar';
      } finally {
        this.loading = false;
      }
    },
    async onClose() {
      this.loading = true;
      this.message = '';
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            action: 'close',
            data: { folio: this.form.folio, usuario: this.form.usuario }
          }
        });
        this.success = res.data.eResponse.success;
        this.message = res.data.eResponse.message;
        if (this.success) {
          this.fetchData();
          this.fetchHistory();
        }
      } catch (e) {
        this.success = false;
        this.message = e.response?.data?.eResponse?.message || 'Error al cerrar';
      } finally {
        this.loading = false;
      }
    },
    async onReopen() {
      this.loading = true;
      this.message = '';
      try {
        const res = await axios.post('/api/execute', {
          eRequest: {
            action: 'reopen',
            data: { folio: this.form.folio, usuario: this.form.usuario }
          }
        });
        this.success = res.data.eResponse.success;
        this.message = res.data.eResponse.message;
        if (this.success) {
          this.fetchData();
          this.fetchHistory();
        }
      } catch (e) {
        this.success = false;
        this.message = e.response?.data?.eResponse?.message || 'Error al reabrir';
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleString();
    }
  }
};
</script>

<style scoped>
.auttranspatr-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: #f8f9fa;
}
</style>

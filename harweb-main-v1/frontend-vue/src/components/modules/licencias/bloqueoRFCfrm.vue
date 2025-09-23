<template>
  <div class="bloqueo-rfc-page">
    <h2>BLOQUEO DE RFC POR INCUMPLIMIENTO PROGRAMA DE AUTOEVALUACIÓN</h2>
    <div class="search-bar">
      <input v-model="searchRfc" @input="onSearchRfc" placeholder="Buscar RFC..." />
      <button @click="onExportExcel">Exportar a Excel</button>
      <button @click="onAdd">Agregar Bloqueo</button>
    </div>
    <table class="bloqueos-table">
      <thead>
        <tr>
          <th @click="sortBy('rfc')">RFC</th>
          <th @click="sortBy('id_tramite')">Trámite</th>
          <th @click="sortBy('licencia')">Licencia</th>
          <th @click="sortBy('hora')">Fecha/Hora</th>
          <th @click="sortBy('vig')">Vigencia</th>
          <th @click="sortBy('capturista')">Capturista</th>
          <th>Motivo</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in sortedRows" :key="row.rfc + '-' + row.id_tramite">
          <td>{{ row.rfc }}</td>
          <td>{{ row.id_tramite }}</td>
          <td>{{ row.licencia }}</td>
          <td>{{ formatDate(row.hora) }}</td>
          <td>{{ row.vig }}</td>
          <td>{{ row.capturista }}</td>
          <td>{{ row.observacion }}</td>
          <td>
            <button @click="onEdit(row)" v-if="row.vig === 'V'">Editar</button>
            <button @click="onDesbloquear(row)" v-if="row.vig === 'V'">Desbloquear</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="showForm" class="modal">
      <div class="modal-content">
        <h3>{{ formMode === 'add' ? 'Agregar Bloqueo RFC' : formMode === 'edit' ? 'Editar Bloqueo RFC' : 'Desbloquear RFC' }}</h3>
        <form @submit.prevent="onSubmit">
          <div>
            <label>Trámite:</label>
            <input v-model="form.id_tramite" :readonly="formMode !== 'add'" required />
            <button v-if="formMode === 'add'" type="button" @click="onBuscarTramite">Buscar</button>
          </div>
          <div>
            <label>Licencia:</label>
            <input v-model="form.licencia" :readonly="true" />
          </div>
          <div>
            <label>RFC:</label>
            <input v-model="form.rfc" :readonly="formMode !== 'add'" required />
          </div>
          <div>
            <label>Propietario:</label>
            <input v-model="form.propietarionvo" readonly />
          </div>
          <div>
            <label>Actividad:</label>
            <input v-model="form.actividad" readonly />
          </div>
          <div>
            <label>Motivo:</label>
            <textarea v-model="form.observacion" required></textarea>
          </div>
          <div class="modal-actions">
            <button type="submit">Aceptar</button>
            <button type="button" @click="onCancel">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="showBuscarTramite" class="modal">
      <div class="modal-content">
        <h3>Buscar Trámite</h3>
        <input v-model="buscarTramiteId" placeholder="ID Trámite" />
        <button @click="buscarTramite">Buscar</button>
        <div v-if="tramiteInfo">
          <p><b>RFC:</b> {{ tramiteInfo.rfc }}</p>
          <p><b>Licencia:</b> {{ tramiteInfo.id_licencia }}</p>
          <p><b>Propietario:</b> {{ tramiteInfo.propietarionvo }}</p>
          <p><b>Actividad:</b> {{ tramiteInfo.actividad }}</p>
        </div>
        <button @click="showBuscarTramite = false">Cerrar</button>
      </div>
    </div>

    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'BloqueoRfcPage',
  data() {
    return {
      rows: [],
      searchRfc: '',
      sortKey: '',
      sortAsc: true,
      showForm: false,
      formMode: 'add', // add | edit | desbloquear
      form: {
        id_tramite: '',
        licencia: '',
        rfc: '',
        propietarionvo: '',
        actividad: '',
        observacion: ''
      },
      showBuscarTramite: false,
      buscarTramiteId: '',
      tramiteInfo: null,
      loading: false,
      error: ''
    }
  },
  computed: {
    sortedRows() {
      let arr = this.rows.slice();
      if (this.sortKey) {
        arr.sort((a, b) => {
          let va = a[this.sortKey] || '';
          let vb = b[this.sortKey] || '';
          if (va < vb) return this.sortAsc ? -1 : 1;
          if (va > vb) return this.sortAsc ? 1 : -1;
          return 0;
        });
      }
      return arr;
    }
  },
  mounted() {
    this.fetchRows();
  },
  methods: {
    fetchRows() {
      this.loading = true;
      this.error = '';
      this.$axios.post('/api/execute', { action: 'getBloqueosRfc' })
        .then(res => {
          this.rows = res.data.data;
        })
        .catch(err => {
          this.error = err.response?.data?.error || err.message;
        })
        .finally(() => this.loading = false);
    },
    onSearchRfc() {
      if (!this.searchRfc) {
        this.fetchRows();
        return;
      }
      this.loading = true;
      this.error = '';
      this.$axios.post('/api/execute', { action: 'searchBloqueosRfc', params: { rfc: this.searchRfc } })
        .then(res => {
          this.rows = res.data.data;
        })
        .catch(err => {
          this.error = err.response?.data?.error || err.message;
        })
        .finally(() => this.loading = false);
    },
    sortBy(key) {
      if (this.sortKey === key) {
        this.sortAsc = !this.sortAsc;
      } else {
        this.sortKey = key;
        this.sortAsc = true;
      }
    },
    formatDate(dt) {
      if (!dt) return '';
      return new Date(dt).toLocaleString();
    },
    onAdd() {
      this.formMode = 'add';
      this.form = { id_tramite: '', licencia: '', rfc: '', propietarionvo: '', actividad: '', observacion: '' };
      this.showForm = true;
    },
    onEdit(row) {
      this.formMode = 'edit';
      this.form = { ...row };
      this.showForm = true;
    },
    onDesbloquear(row) {
      this.formMode = 'desbloquear';
      this.form = { ...row };
      this.showForm = true;
    },
    onBuscarTramite() {
      this.showBuscarTramite = true;
      this.buscarTramiteId = '';
      this.tramiteInfo = null;
    },
    buscarTramite() {
      if (!this.buscarTramiteId) return;
      this.loading = true;
      this.error = '';
      this.$axios.post('/api/execute', { action: 'getTramiteInfo', params: { id_tramite: this.buscarTramiteId } })
        .then(res => {
          this.tramiteInfo = res.data.data;
          // Autollenado
          this.form.id_tramite = this.tramiteInfo.id_tramite;
          this.form.licencia = this.tramiteInfo.id_licencia;
          this.form.rfc = this.tramiteInfo.rfc;
          this.form.propietarionvo = this.tramiteInfo.propietarionvo;
          this.form.actividad = this.tramiteInfo.actividad;
        })
        .catch(err => {
          this.error = err.response?.data?.error || err.message;
        })
        .finally(() => this.loading = false);
    },
    onSubmit() {
      this.loading = true;
      this.error = '';
      let action = '';
      if (this.formMode === 'add') action = 'addBloqueoRfc';
      else if (this.formMode === 'edit') action = 'editBloqueoRfc';
      else if (this.formMode === 'desbloquear') action = 'desbloquearRfc';
      this.$axios.post('/api/execute', { action, params: this.form })
        .then(res => {
          this.showForm = false;
          this.fetchRows();
        })
        .catch(err => {
          this.error = err.response?.data?.error || err.message;
        })
        .finally(() => this.loading = false);
    },
    onCancel() {
      this.showForm = false;
    },
    onExportExcel() {
      window.open('/api/execute?action=exportBloqueosRfc', '_blank');
    }
  }
}
</script>

<style scoped>
.bloqueo-rfc-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.search-bar {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}
.bloqueos-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 2rem;
}
.bloqueos-table th, .bloqueos-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.bloqueos-table th {
  background: #f0f0f0;
  cursor: pointer;
}
.modal {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-content {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  min-width: 350px;
}
.loading {
  color: #007bff;
  font-weight: bold;
}
.error {
  color: #c00;
  font-weight: bold;
}
</style>

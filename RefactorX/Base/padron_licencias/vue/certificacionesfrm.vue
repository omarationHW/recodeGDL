<template>
  <div class="certificaciones-page">
    <h1>Certificación de Licencias y Anuncios</h1>
    <div class="actions">
      <button @click="showForm('new')">Nueva</button>
      <button :disabled="!selectedId" @click="showForm('edit')">Modificar</button>
      <button :disabled="!selectedId" @click="cancelCert">Cancelar Certificación</button>
      <button :disabled="!selectedId" @click="printCert">Imprimir</button>
      <button @click="showListado">Listado</button>
    </div>
    <div v-if="showListadoTable">
      <h2>Listado de Certificaciones</h2>
      <form @submit.prevent="fetchListado">
        <label>Año: <input v-model="search.axo" type="number" /></label>
        <label>Folio: <input v-model="search.folio" type="number" /></label>
        <label>Licencia: <input v-model="search.id_licencia" type="number" /></label>
        <label>Fecha inicio: <input v-model="search.feccap_ini" type="date" /></label>
        <label>Fecha fin: <input v-model="search.feccap_fin" type="date" /></label>
        <label>Tipo:
          <select v-model="search.tipo">
            <option value="L">Licencia</option>
            <option value="A">Anuncio</option>
          </select>
        </label>
        <button type="submit">Buscar</button>
      </form>
      <table class="table">
        <thead>
          <tr>
            <th>Año</th>
            <th>Folio</th>
            <th>Licencia</th>
            <th>Observación</th>
            <th>Vigente</th>
            <th>Fecha</th>
            <th>Capturista</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in listado" :key="row.id" @click="selectRow(row)">
            <td>{{ row.axo }}</td>
            <td>{{ row.folio }}</td>
            <td>{{ row.licencia || row.id_licencia }}</td>
            <td>{{ row.observacion }}</td>
            <td>{{ row.vigente === 'V' ? 'Vigente' : 'Cancelado' }}</td>
            <td>{{ row.feccap }}</td>
            <td>{{ row.capturista }}</td>
          </tr>
        </tbody>
      </table>
      <div v-if="listado.length === 0">No hay registros.</div>
    </div>
    <div v-if="showFormDialog">
      <h2 v-if="formMode==='new'">Nueva Certificación</h2>
      <h2 v-else>Modificar Certificación</h2>
      <form @submit.prevent="submitForm">
        <label>Tipo:
          <select v-model="form.tipo">
            <option value="L">Licencia</option>
            <option value="A">Anuncio</option>
          </select>
        </label>
        <label>Licencia/Anuncio ID:
          <input v-model.number="form.id_licencia" type="number" required />
        </label>
        <label>Observación:
          <input v-model="form.observacion" maxlength="200" />
        </label>
        <label>Partida de Pago:
          <input v-model="form.partidapago" maxlength="25" />
        </label>
        <div class="form-actions">
          <button type="submit">Aceptar</button>
          <button type="button" @click="closeForm">Cancelar</button>
        </div>
      </form>
    </div>
    <div v-if="showPrintDialog">
      <h2>Impresión de Certificación</h2>
      <div v-if="printData">
        <pre>{{ printData }}</pre>
        <button @click="closePrint">Cerrar</button>
      </div>
      <div v-else>Cargando...</div>
    </div>
    <div v-if="showCancelDialog">
      <h2>Cancelar Certificación</h2>
      <form @submit.prevent="confirmCancel">
        <label>Motivo de cancelación:
          <input v-model="cancelMotivo" required />
        </label>
        <button type="submit">Confirmar</button>
        <button type="button" @click="closeCancel">Cancelar</button>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CertificacionesPage',
  data() {
    return {
      listado: [],
      selectedId: null,
      showFormDialog: false,
      showListadoTable: true,
      showPrintDialog: false,
      showCancelDialog: false,
      formMode: 'new',
      form: {
        tipo: 'L',
        id_licencia: '',
        observacion: '',
        partidapago: ''
      },
      search: {
        axo: '',
        folio: '',
        id_licencia: '',
        feccap_ini: '',
        feccap_fin: '',
        tipo: 'L'
      },
      printData: null,
      cancelMotivo: ''
    };
  },
  mounted() {
    this.fetchListado();
  },
  methods: {
    fetchListado() {
      this.selectedId = null;
      this.$axios.post('/api/execute', {
        action: 'certificaciones.listado',
        params: this.search
      }).then(res => {
        this.listado = res.data.data;
      });
    },
    selectRow(row) {
      this.selectedId = row.id;
      this.form = { ...row };
    },
    showForm(mode) {
      this.formMode = mode;
      if (mode === 'edit' && this.selectedId) {
        this.form = { ...this.listado.find(r => r.id === this.selectedId) };
      } else {
        this.form = { tipo: 'L', id_licencia: '', observacion: '', partidapago: '' };
      }
      this.showFormDialog = true;
      this.showListadoTable = false;
    },
    closeForm() {
      this.showFormDialog = false;
      this.showListadoTable = true;
    },
    submitForm() {
      const action = this.formMode === 'new' ? 'certificaciones.create' : 'certificaciones.update';
      this.$axios.post('/api/execute', {
        action,
        params: this.form
      }).then(res => {
        this.showFormDialog = false;
        this.showListadoTable = true;
        this.fetchListado();
      });
    },
    cancelCert() {
      this.cancelMotivo = '';
      this.showCancelDialog = true;
    },
    confirmCancel() {
      this.$axios.post('/api/execute', {
        action: 'certificaciones.cancel',
        params: { id: this.selectedId, motivo: this.cancelMotivo }
      }).then(res => {
        this.showCancelDialog = false;
        this.fetchListado();
      });
    },
    closeCancel() {
      this.showCancelDialog = false;
    },
    printCert() {
      this.showPrintDialog = true;
      this.printData = null;
      this.$axios.post('/api/execute', {
        action: 'certificaciones.print',
        params: { id: this.selectedId }
      }).then(res => {
        this.printData = JSON.stringify(res.data, null, 2);
      });
    },
    closePrint() {
      this.showPrintDialog = false;
    },
    showListado() {
      this.showListadoTable = true;
      this.showFormDialog = false;
      this.showPrintDialog = false;
      this.showCancelDialog = false;
      this.fetchListado();
    }
  }
};
</script>

<style scoped>
.certificaciones-page {
  max-width: 900px;
  margin: 0 auto;
}
.actions {
  margin-bottom: 1em;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 4px 8px;
}
tr.selected {
  background: #e0e0e0;
}
.form-actions {
  margin-top: 1em;
}
</style>

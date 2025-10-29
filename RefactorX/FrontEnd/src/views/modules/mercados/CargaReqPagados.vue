<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Carga Req Pagados</h1>
        <p>Mercados - Gestión de Pagos</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="carga-req-pagados-page">
          <div class="breadcrumb">
            <router-link to="/">Inicio</router-link> / Carga de Requerimientos Pagados
          </div>
          <h1>Carga de Pagos Realizados en Mdo. Libertad</h1>
          <div class="panel panel-default mb-3 p-3">
            <label for="file">Seleccionar archivo de pagos (TXT):</label>
            <input type="file" id="file" @change="onFileChange" accept=".txt" />
            <button class="btn-municipal-primary" @click="parseFile" :disabled="!file">Cargar Archivo</button>
          </div>
          <div v-if="rows.length > 0">
            <div class="municipal-table" style="max-height: 350px; overflow:auto;">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr class="row-hover">
                    <th>Pagos</th>
                    <th>Id Local</th>
                    <th>Fecha Pago</th>
                    <th>Oficina</th>
                    <th>Caja</th>
                    <th>Operacion</th>
                    <th>Folio</th>
                    <th>Fecha Actualizacion</th>
                    <th>Usuario</th>
                    <th>Imp. Multa</th>
                    <th>Imp. Gastos</th>
                    <th>Folios Requerimientos</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, idx) in rows" :key="idx" class="row-hover">
                    <td>{{ row.pagos }}</td>
                    <td>{{ row.id_local }}</td>
                    <td>{{ row.fecha_pago }}</td>
                    <td>{{ row.oficina }}</td>
                    <td>{{ row.caja }}</td>
                    <td>{{ row.operacion }}</td>
                    <td>{{ row.folio }}</td>
                    <td>{{ row.fecha_actualizacion }}</td>
                    <td>{{ row.usuario }}</td>
                    <td>{{ row.imp_multa }}</td>
                    <td>{{ row.imp_gastos }}</td>
                    <td>{{ row.folios_requerimientos }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="mt-3">
              <button class="btn btn-success" @click="procesarPagos" :disabled="procesando">Actualizar Pagos</button>
              <button class="btn-municipal-secondary" @click="reset">Limpiar</button>
            </div>
          </div>
          <div v-if="totales">
            <div class="alert alert-info mt-4">
              <div><b>Folios Grabados:</b> {{ totales.grabados }}</div>
              <div><b>Total de Locales:</b> {{ totales.total_pag }}</div>
              <div><b>Total de Multa:</b> ${{ totales.importe_multa.toFixed(2) }}</div>
              <div><b>Total de Gastos:</b> ${{ totales.importe_gastos.toFixed(2) }}</div>
            </div>
          </div>
          <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'CargaReqPagados'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  components: {
    DocumentationModal
  },
  name: 'CargaReqPagados',
  data() {
    return {
      file: null,
      rows: [],
      totales: null,
      error: '',
      procesando: false,
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }};
  },
  methods: {
    openDocumentation() {
      this.showDocumentation = true;
    },
    closeDocumentation() {
      this.showDocumentation = false;
    },
    showToast(type, message) {
      this.toast = { show: true, type, message };
      setTimeout(() => this.hideToast(), 3000);
    },
    hideToast() {
      this.toast.show = false;
    },
    getToastIcon(type) {
      const icons = {
        success: 'check-circle',
        error: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
      };
      return icons[type] || 'info-circle';
    },
    onFileChange(e) {
      this.file = e.target.files[0];
      this.rows = [];
      this.totales = null;
      this.error = '';
    },
    parseFile() {
      if (!this.file) return;
      const reader = new FileReader();
      reader.onload = (e) => {
        const lines = e.target.result.split(/\r?\n/).filter(l => l.trim() !== '');
        this.rows = lines.map((line, idx) => {
          return {
            pagos: idx + 1,
            id_local: line.substr(0, 6).trim(),
            fecha_pago: line.substr(6, 2) + '/' + line.substr(8, 2) + '/' + line.substr(10, 4),
            oficina: line.substr(14, 3).trim(),
            caja: line.substr(17, 1).trim(),
            operacion: line.substr(18, 5).trim(),
            folio: line.substr(23, 6).trim(),
            fecha_actualizacion: line.substr(29, 19).trim(),
            usuario: line.substr(48, 3).trim(),
            imp_multa: line.substr(75, 9).trim(),
            imp_gastos: line.substr(84, 9).trim(),
            folios_requerimientos: line.substr(93, 150).trim()
          };
        });
      };
      reader.readAsText(this.file);
    },
    async procesarPagos() {
      this.procesando = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'processPagos',
              data: {
                registros: this.rows
              }
            }
          })
        });
        const json = await res.json();
        if (json.eResponse.status === 'ok') {
          this.totales = json.eResponse.data;
        } else {
          this.error = (json.eResponse.errors || []).join(', ');
        }
      } catch (err) {
        this.error = err.message;
      }
      this.procesando = false;
    },
    reset() {
      this.file = null;
      this.rows = [];
      this.totales = null;
      this.error = '';
      this.$refs.file && (this.$refs.file.value = '');
    }
  }
};
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>

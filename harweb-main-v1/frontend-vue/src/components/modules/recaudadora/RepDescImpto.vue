<template>
  <div class="rep-desc-impto">
    <h1>Reporte de Descuentos de Impuesto Predial</h1>
    <form @submit.prevent="buscar">
      <div class="form-row">
        <label>Tipo de Archivo:</label>
        <select v-model="form.tipoArchivo">
          <option value="aplicados">Aplicados</option>
          <option value="reactivados">Reactivados</option>
        </select>
      </div>
      <div class="form-row">
        <label>Filtrar por:</label>
        <select v-model="form.tipoFecha">
          <option :value="0">Todos</option>
          <option :value="1">Fecha Alta</option>
          <option :value="2">Fecha Baja</option>
        </select>
      </div>
      <div class="form-row" v-if="form.tipoFecha !== 0">
        <label>Desde:</label>
        <input type="date" v-model="form.fecha1" />
        <label>Hasta:</label>
        <input type="date" v-model="form.fecha2" />
      </div>
      <div class="form-row">
        <label>Recaudadora:</label>
        <select v-model="form.recaudadora">
          <option value="">Todas</option>
          <option v-for="rec in catalogs.recaudadoras" :key="rec.id_recau" :value="rec.id_recau">{{ rec.nombredepto }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Tipo de Descuento:</label>
        <select v-model="form.tipoDescuento">
          <option value="">Todos</option>
          <option v-for="td in catalogs.tipos_descuento" :key="td.cvedescuento" :value="td.cvedescuento">{{ td.tipo }}</option>
        </select>
      </div>
      <div class="form-row">
        <button type="submit">Buscar</button>
        <button type="button" @click="exportarExcel">Exportar Excel</button>
      </div>
    </form>
    <div v-if="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="resultados.length">
      <table class="table table-bordered table-sm mt-3">
        <thead>
          <tr>
            <th>Cuenta</th>
            <th>Propietario</th>
            <th>Solicitante</th>
            <th>Fec Nac</th>
            <th>Institución</th>
            <th>No. Identificación</th>
            <th>Vig</th>
            <th>Folio</th>
            <th>Observaciones</th>
            <th>Descuento</th>
            <th>Año</th>
            <th>Bimestres</th>
            <th>Impte Adeudo</th>
            <th>Usuario Alta</th>
            <th>Usuario Baja</th>
            <th>Fecha Alta</th>
            <th>Fecha Baja</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in resultados" :key="row.foliodesc">
            <td>{{ row.cvecuenta }}</td>
            <td>{{ row.propie }}</td>
            <td>{{ row.solicitante }}</td>
            <td>{{ row.fecnac ? row.fecnac.substr(0,10) : '' }}</td>
            <td>{{ row.institucion }}</td>
            <td>{{ row.identificacion }}</td>
            <td>{{ row.vigen }}</td>
            <td>{{ row.foliodesc }}</td>
            <td>{{ row.observaciones }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.axodescto }}</td>
            <td>{{ row.bimini }} - {{ row.bimfin }}</td>
            <td>{{ row.adeudo }}</td>
            <td>{{ row.usualta }}</td>
            <td>{{ row.usubaja }}</td>
            <td>{{ row.fecalta ? row.fecalta.substr(0,10) : '' }}</td>
            <td>{{ row.fecbaja ? row.fecbaja.substr(0,10) : '' }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-2">Total registros: {{ resultados.length }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RepDescImpto',
  data() {
    return {
      catalogs: {
        recaudadoras: [],
        tipos_descuento: []
      },
      form: {
        tipoArchivo: 'aplicados',
        tipoFecha: 0,
        fecha1: '',
        fecha2: '',
        recaudadora: '',
        tipoDescuento: ''
      },
      resultados: [],
      loading: false,
      error: ''
    }
  },
  created() {
    this.cargarCatalogos();
  },
  methods: {
    async cargarCatalogos() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action: 'getCatalogs' }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.catalogs = data.eResponse.data;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async buscar() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getDescuentos',
              params: this.form
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.resultados = data.eResponse.data;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    exportarExcel() {
      // Exportar tabla a Excel usando frontend (ejemplo simple)
      // Puede usarse xlsx, SheetJS, o window.print()
      window.print();
    }
  }
}
</script>

<style scoped>
.rep-desc-impto {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 180px;
  font-weight: bold;
}
.form-row input, .form-row select {
  flex: 1;
  margin-right: 1rem;
}
.table {
  font-size: 0.95rem;
}
.error {
  color: red;
  margin: 1rem 0;
}
</style>

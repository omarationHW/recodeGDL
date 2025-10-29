<template>
  <div class="gadeudosgral-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Adeudos Generales Anualizados</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">{{ tablaNombre }}</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="onConsultar">
          <div class="row mb-2">
            <div class="col-md-4">
              <label>Tipo de Reporte</label>
              <select v-model="tipoReporte" class="form-control">
                <option value="A">A .- Total General</option>
                <option value="B">B .- Total General Anualizado</option>
                <option value="C">C .- Total General Adeudos - Pagos</option>
              </select>
            </div>
            <div class="col-md-4">
              <label>Opción</label>
              <select v-model="tipoOpcion" class="form-control">
                <option value="T">T .- TODOS</option>
                <option value="W">W .- SIN ADEUDO ALGUNO</option>
                <option value="U">U .- CON SOLO ADEUDOS DE REQ. Y PERIODOS EN CEROS</option>
                <option value="R">R .- CON SOLO ADEUDOS DE PERIODOS Y REQ. EN CEROS</option>
                <option value="S">S .- CON ADEUDO ALGUNO</option>
              </select>
            </div>
            <div class="col-md-4">
              <label>Periodo</label>
              <select v-model="periodo" class="form-control" @change="onPeriodoChange">
                <option value="actual">Periodo Actual</option>
                <option value="otro">Otro Periodo</option>
              </select>
            </div>
          </div>
          <div class="row mb-2" v-if="periodo === 'otro'">
            <div class="col-md-2">
              <label>Año</label>
              <input v-model="anio" type="number" class="form-control" min="2000" max="2100" />
            </div>
            <div class="col-md-2">
              <label>Mes</label>
              <select v-model="mes" class="form-control">
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.text }}</option>
              </select>
            </div>
          </div>
          <div class="row mb-2">
            <div class="col-md-12">
              <button type="submit" class="btn btn-success mr-2">Consultar</button>
              <button type="button" class="btn btn-outline-primary mr-2" @click="onVistaAdeudo">Vista Adeudo</button>
              <button type="button" class="btn btn-outline-secondary" @click="onExportarExcel">Exportar a Excel</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="card">
      <div class="card-body">
        <h5 class="card-title">Resultados</h5>
        <div v-if="loading" class="text-center my-4">
          <span class="spinner-border"></span> Cargando...
        </div>
        <div v-else>
          <table class="table table-bordered table-sm table-hover">
            <thead>
              <tr>
                <th>Control</th>
                <th>Nombre</th>
                <th>Superficie</th>
                <th>Periodos</th>
                <th>Adeudo</th>
                <th>Recargos</th>
                <th>Descto. Recargos</th>
                <th>Multa</th>
                <th>Descto. Multa</th>
                <th>Actualización</th>
                <th>Gastos</th>
                <th>Forma</th>
                <th>Autorización</th>
                <th>Total</th>
                <th>Ubicación</th>
                <th>Tipo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in resultados" :key="row.control">
                <td>{{ row.control }}</td>
                <td>{{ row.nombre }}</td>
                <td>{{ row.superficie }}</td>
                <td>{{ row.periodos }}</td>
                <td>{{ row.adeudo }}</td>
                <td>{{ row.recargos }}</td>
                <td>{{ row.desc_recargos }}</td>
                <td>{{ row.multa }}</td>
                <td>{{ row.desc_multa }}</td>
                <td>{{ row.actualizacion }}</td>
                <td>{{ row.gastos }}</td>
                <td>{{ row.forma }}</td>
                <td>{{ row.autorizacion }}</td>
                <td>{{ row.total }}</td>
                <td>{{ row.ubicacion }}</td>
                <td>{{ row.tipo }}</td>
              </tr>
            </tbody>
          </table>
          <div v-if="resultados.length === 0" class="alert alert-info">No hay resultados para los filtros seleccionados.</div>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'GAdeudosGralPage',
  data() {
    const now = new Date();
    return {
      tablaNombre: 'Adeudos Generales Anualizados',
      tipoReporte: 'A',
      tipoOpcion: 'T',
      periodo: 'actual',
      anio: now.getFullYear(),
      mes: (now.getMonth() + 1).toString().padStart(2, '0'),
      meses: [
        { value: '01', text: 'Enero' },
        { value: '02', text: 'Febrero' },
        { value: '03', text: 'Marzo' },
        { value: '04', text: 'Abril' },
        { value: '05', text: 'Mayo' },
        { value: '06', text: 'Junio' },
        { value: '07', text: 'Julio' },
        { value: '08', text: 'Agosto' },
        { value: '09', text: 'Septiembre' },
        { value: '10', text: 'Octubre' },
        { value: '11', text: 'Noviembre' },
        { value: '12', text: 'Diciembre' }
      ],
      resultados: [],
      loading: false,
      error: '',
      gloOpc: 3 // Por ejemplo, tabla 3 (Rastro)
    };
  },
  created() {
    this.fetchTablaNombre();
  },
  methods: {
    fetchTablaNombre() {
      axios.post('/api/execute', {
        eRequest: {
          operation: 'GAdeudosGral.getTablas',
          params: { par_tab: this.gloOpc }
        }
      }).then(res => {
        if (res.data.eResponse.success && res.data.eResponse.data.length > 0) {
          this.tablaNombre = res.data.eResponse.data[0].nombre;
        }
      });
    },
    onPeriodoChange() {
      if (this.periodo === 'actual') {
        const now = new Date();
        this.anio = now.getFullYear();
        this.mes = (now.getMonth() + 1).toString().padStart(2, '0');
      }
    },
    onConsultar() {
      this.loading = true;
      this.error = '';
      let par_fecha = '';
      if (this.periodo === 'actual') {
        const now = new Date();
        par_fecha = `${now.getFullYear()}-${(now.getMonth() + 1).toString().padStart(2, '0')}`;
      } else {
        par_fecha = `${this.anio}-${this.mes}`;
      }
      axios.post('/api/execute', {
        eRequest: {
          operation: 'GAdeudosGral.sp34_adeudototal',
          params: {
            par_tabla: this.gloOpc,
            par_fecha: par_fecha
          }
        }
      }).then(res => {
        if (res.data.eResponse.success) {
          this.resultados = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error al consultar.';
        }
      }).catch(err => {
        this.error = err.message;
      }).finally(() => {
        this.loading = false;
      });
    },
    onVistaAdeudo() {
      // Simula la consulta de adeudos por año/mes seleccionados
      this.onConsultar();
    },
    onExportarExcel() {
      // Simula exportación (en real, backend debe generar archivo y devolver url)
      this.loading = true;
      axios.post('/api/execute', {
        eRequest: {
          operation: 'GAdeudosGral.exportExcel',
          params: {}
        }
      }).then(res => {
        if (res.data.eResponse.success && res.data.eResponse.data.url) {
          window.open(res.data.eResponse.data.url, '_blank');
        } else {
          this.error = 'No se pudo exportar.';
        }
      }).catch(err => {
        this.error = err.message;
      }).finally(() => {
        this.loading = false;
      });
    }
  }
};
</script>

<style scoped>
.gadeudosgral-page {
  max-width: 1200px;
  margin: 0 auto;
}
.card {
  margin-bottom: 1rem;
}
</style>

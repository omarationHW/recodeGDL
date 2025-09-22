<template>
  <div class="padron-con-adeudos-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Padrón con Adeudos</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header bg-primary text-white">
        <h4>{{ nombreTabla }}</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="onBuscar">
          <div class="row mb-2">
            <div class="col-md-4">
              <label for="vigencia">Vigencia de la Concesión</label>
              <select v-model="vigenciaSeleccionada" class="form-control" id="vigencia">
                <option value="TODOS">TODOS</option>
                <option v-for="vig in vigencias" :key="vig.descripcion" :value="vig.descripcion">
                  {{ vig.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-4">
              <label for="periodo">Periodo</label>
              <select v-model="periodoTipo" class="form-control" id="periodo" @change="onPeriodoTipoChange">
                <option value="vencidos">Periodos Vencidos</option>
                <option value="otro">Otro Periodo</option>
              </select>
            </div>
            <div class="col-md-2" v-if="periodoTipo === 'otro'">
              <label for="anio">Año</label>
              <input v-model="anio" type="number" class="form-control" id="anio" maxlength="4" min="2000" :max="anioActual" />
            </div>
            <div class="col-md-2" v-if="periodoTipo === 'otro'">
              <label for="mes">Mes</label>
              <select v-model="mes" class="form-control" id="mes">
                <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
              </select>
            </div>
          </div>
          <div class="row mb-2">
            <div class="col-md-6">
              <button type="submit" class="btn btn-success mr-2"><i class="fa fa-search"></i> Buscar</button>
              <button type="button" class="btn btn-primary" @click="onImprimir"><i class="fa fa-print"></i> Imprimir</button>
            </div>
          </div>
        </form>
        <div v-if="loading" class="text-center my-3">
          <span class="spinner-border"></span> Cargando datos...
        </div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="padron.length > 0">
          <table class="table table-bordered table-sm mt-3">
            <thead class="thead-light">
              <tr>
                <th>{{ etiquetas.control || 'Control' }}</th>
                <th>{{ etiquetas.concesionario || 'Concesionario' }}</th>
                <th>{{ etiquetas.superficie || 'Superficie' }}</th>
                <th>{{ etiquetas.recaudadora || 'Ofna' }}</th>
                <th>{{ etiquetas.sector || 'Sector' }}</th>
                <th>{{ etiquetas.zona || 'Zona' }}</th>
                <th>{{ etiquetas.licencia || 'Licencia' }}</th>
                <th>Detalle</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in padron" :key="row.id_34_datos">
                <td>{{ row.control }}</td>
                <td>{{ row.concesionario }}</td>
                <td>{{ row.superficie }}</td>
                <td>{{ row.recaudadora }}</td>
                <td>{{ row.sector }}</td>
                <td>{{ row.zona }}</td>
                <td>{{ row.licencia }}</td>
                <td>
                  <button class="btn btn-link btn-sm" @click="verDetalle(row)"><i class="fa fa-eye"></i> Ver</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-if="detalleAdeudos.length > 0">
          <h5 class="mt-4">Detalle de Adeudos</h5>
          <table class="table table-bordered table-sm">
            <thead class="thead-light">
              <tr>
                <th>Concepto</th>
                <th>Adeudos</th>
                <th>Recargos</th>
                <th>Multa</th>
                <th>Gastos</th>
                <th>Actualización</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="det in detalleAdeudos" :key="det.concepto">
                <td>{{ det.concepto }}</td>
                <td>{{ det.importe_adeudos | currency }}</td>
                <td>{{ det.importe_recargos | currency }}</td>
                <td>{{ det.importe_multa | currency }}</td>
                <td>{{ det.importe_gastos | currency }}</td>
                <td>{{ det.importe_actualizacion | currency }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="font-weight-bold">
                <td>Total</td>
                <td>{{ suma('importe_adeudos') | currency }}</td>
                <td>{{ suma('importe_recargos') | currency }}</td>
                <td>{{ suma('importe_multa') | currency }}</td>
                <td>{{ suma('importe_gastos') | currency }}</td>
                <td>{{ suma('importe_actualizacion') | currency }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'PadronConAdeudosPage',
  data() {
    const now = new Date();
    return {
      nombreTabla: '',
      etiquetas: {},
      vigencias: [],
      vigenciaSeleccionada: 'TODOS',
      periodoTipo: 'vencidos',
      anio: now.getFullYear(),
      anioActual: now.getFullYear(),
      mes: String(now.getMonth() + 1).padStart(2, '0'),
      meses: ['01','02','03','04','05','06','07','08','09','10','11','12'],
      padron: [],
      detalleAdeudos: [],
      loading: false,
      error: '',
      par_tabla: 3 // Por defecto, puede venir por props o ruta
    };
  },
  created() {
    this.cargarNombreTabla();
    this.cargarEtiquetas();
    this.cargarVigencias();
    this.buscarPadron();
  },
  methods: {
    cargarNombreTabla() {
      axios.post('/api/execute', {
        action: 'getNombreTabla',
        params: { par_tab: this.par_tabla }
      }).then(resp => {
        if (resp.data.success && resp.data.data.length > 0) {
          this.nombreTabla = resp.data.data[0].nombre;
        }
      });
    },
    cargarEtiquetas() {
      axios.post('/api/execute', {
        action: 'getEtiquetasTabla',
        params: { par_tab: this.par_tabla }
      }).then(resp => {
        if (resp.data.success && resp.data.data.length > 0) {
          this.etiquetas = resp.data.data[0];
        }
      });
    },
    cargarVigencias() {
      axios.post('/api/execute', {
        action: 'getVigenciasConcesion',
        params: { par_tab: this.par_tabla }
      }).then(resp => {
        if (resp.data.success) {
          this.vigencias = resp.data.data;
        }
      });
    },
    onPeriodoTipoChange() {
      if (this.periodoTipo === 'vencidos') {
        this.anio = this.anioActual;
        this.mes = String(new Date().getMonth() + 1).padStart(2, '0');
      } else {
        this.anio = '';
        this.mes = '01';
      }
    },
    onBuscar() {
      this.buscarPadron();
      this.detalleAdeudos = [];
    },
    buscarPadron() {
      this.loading = true;
      this.error = '';
      axios.post('/api/execute', {
        action: 'getPadronConAdeudos',
        params: {
          par_tabla: this.par_tabla,
          par_vigencia: this.vigenciaSeleccionada
        }
      }).then(resp => {
        if (resp.data.success) {
          this.padron = resp.data.data;
        } else {
          this.error = resp.data.message || 'Error al cargar datos';
        }
      }).catch(e => {
        this.error = e.message;
      }).finally(() => {
        this.loading = false;
      });
    },
    verDetalle(row) {
      let par_rep = this.periodoTipo === 'vencidos' ? 'V' : 'A';
      let par_fecha = this.anio + '-' + this.mes;
      axios.post('/api/execute', {
        action: 'getPadronAdeudosDetalle',
        params: {
          par_tab: this.par_tabla,
          par_control: row.id_34_datos,
          par_rep,
          par_fecha
        }
      }).then(resp => {
        if (resp.data.success) {
          this.detalleAdeudos = resp.data.data;
        } else {
          this.error = resp.data.message || 'Error al cargar detalle';
        }
      });
    },
    onImprimir() {
      window.print();
    },
    suma(campo) {
      return this.detalleAdeudos.reduce((acc, item) => acc + (parseFloat(item[campo]) || 0), 0);
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') val = parseFloat(val) || 0;
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.padron-con-adeudos-page {
  max-width: 1200px;
  margin: 0 auto;
}
.breadcrumb {
  background: #f8f9fa;
}
.card-header {
  font-size: 1.2rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>

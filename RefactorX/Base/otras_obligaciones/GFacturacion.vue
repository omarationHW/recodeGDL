<template>
  <div class="gfacturacion-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Facturación General</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4>Facturación General</h4>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <label class="form-label">Tabla</label>
          <select v-model="selectedTabla" class="form-select" @change="fetchEtiquetas">
            <option v-for="t in tablas" :key="t.cve_tab" :value="t.cve_tab">{{ t.nombre }}</option>
          </select>
        </div>
        <div class="mb-3">
          <label class="form-label">Periodo</label>
          <select v-model="periodo" class="form-select" @change="onPeriodoChange">
            <option value="actual">Periodo Actual</option>
            <option value="otro">Otro Periodo</option>
          </select>
        </div>
        <div class="row mb-3" v-if="periodo === 'otro'">
          <div class="col-md-3">
            <label class="form-label">Año</label>
            <input type="number" v-model="axo" class="form-control" min="2000" max="2100" />
          </div>
          <div class="col-md-3">
            <label class="form-label">Mes</label>
            <select v-model="mes" class="form-select">
              <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
            </select>
          </div>
        </div>
        <div class="mb-3">
          <label class="form-label">Tipo de Consulta</label>
          <select v-model="adeudosStatus" class="form-select" @change="onStatusChange">
            <option value="A">Adeudos y Pagos</option>
            <option value="B">Solo Adeudos</option>
            <option value="C">Solo Pagados</option>
          </select>
        </div>
        <div class="mb-3" v-if="adeudosStatus !== 'C'">
          <input type="checkbox" v-model="conRecargos" id="chkRecargos" />
          <label for="chkRecargos">Adeudos con recargos</label>
        </div>
        <div class="mb-3">
          <button class="btn btn-success" @click="fetchFacturacion"><i class="bi bi-search"></i> Consultar</button>
        </div>
        <div v-if="loading" class="alert alert-info">Cargando datos...</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="facturacion.length">
          <h5 class="mt-4">Resultados</h5>
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th>Control</th>
                <th>Concesionario</th>
                <th>Superficie</th>
                <th>Tipo</th>
                <th>Licencia</th>
                <th>Importe</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in facturacion" :key="row.control">
                <td>{{ row.control }}</td>
                <td>{{ row.concesionario }}</td>
                <td>{{ row.superficie }}</td>
                <td>{{ row.tipo }}</td>
                <td>{{ row.licencia }}</td>
                <td>{{ row.importe | currency }}</td>
              </tr>
            </tbody>
          </table>
          <div class="mt-3">
            <strong>Total: </strong> {{ totalImporte | currency }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'GFacturacionPage',
  data() {
    const now = new Date();
    return {
      tablas: [],
      etiquetas: {},
      selectedTabla: '',
      periodo: 'actual',
      axo: now.getFullYear(),
      mes: now.getMonth() + 1,
      meses: [],
      adeudosStatus: 'A',
      conRecargos: false,
      facturacion: [],
      loading: false,
      error: '',
    };
  },
  computed: {
    totalImporte() {
      return this.facturacion.reduce((sum, row) => sum + Number(row.importe || 0), 0);
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  mounted() {
    this.fetchTablas();
    this.fetchMeses();
  },
  methods: {
    async fetchTablas() {
      this.loading = true;
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            operation: 'getTablas',
            params: { par_tab: 3 } // Default tabla (Rastro)
          }
        });
        this.tablas = data.eResponse.data || [];
        if (this.tablas.length) {
          this.selectedTabla = this.tablas[0].cve_tab;
          this.fetchEtiquetas();
        }
      } catch (e) {
        this.error = 'Error al cargar tablas';
      } finally {
        this.loading = false;
      }
    },
    async fetchEtiquetas() {
      if (!this.selectedTabla) return;
      this.loading = true;
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            operation: 'getEtiquetas',
            params: { par_tab: this.selectedTabla }
          }
        });
        this.etiquetas = data.eResponse.data && data.eResponse.data[0] ? data.eResponse.data[0] : {};
      } catch (e) {
        this.error = 'Error al cargar etiquetas';
      } finally {
        this.loading = false;
      }
    },
    async fetchMeses() {
      const { data } = await axios.post('/api/execute', {
        eRequest: { operation: 'getMeses' }
      });
      this.meses = data.eResponse.data;
    },
    onPeriodoChange() {
      if (this.periodo === 'actual') {
        const now = new Date();
        this.axo = now.getFullYear();
        this.mes = now.getMonth() + 1;
      }
    },
    onStatusChange() {
      if (this.adeudosStatus === 'C') {
        this.conRecargos = false;
      }
    },
    async fetchFacturacion() {
      this.error = '';
      this.facturacion = [];
      if (!this.selectedTabla) {
        this.error = 'Debe seleccionar una tabla.';
        return;
      }
      let par_Axo = this.axo;
      let par_Mes = this.mes;
      if (this.periodo === 'actual') {
        const now = new Date();
        par_Axo = now.getFullYear();
        par_Mes = now.getMonth() + 1;
      }
      let par_Ade = this.adeudosStatus;
      let Par_Rcgo = this.adeudosStatus === 'C' ? 'N' : (this.conRecargos ? 'S' : 'N');
      this.loading = true;
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            operation: 'getFacturacion',
            params: {
              par_Tab: this.selectedTabla,
              par_Ade: par_Ade,
              Par_Rcgo: Par_Rcgo,
              par_Axo: par_Axo,
              par_Mes: par_Mes
            }
          }
        });
        if (data.eResponse.success) {
          this.facturacion = data.eResponse.data || [];
        } else {
          this.error = data.eResponse.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = 'Error al consultar facturación';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.gfacturacion-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  margin-top: 20px;
}
</style>

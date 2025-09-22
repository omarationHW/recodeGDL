<template>
  <div class="procesos-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Procesos Aseo</li>
      </ol>
    </nav>
    <h1>Procesos de Aseo</h1>
    <div class="form-group">
      <label for="tipoAseo">Tipo de Aseo</label>
      <select v-model="selectedTipo" @change="onTipoChange" class="form-control" id="tipoAseo">
        <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
          {{ tipo.descripcion }}
        </option>
      </select>
    </div>
    <div v-if="dashboard">
      <h2>Resumen</h2>
      <div class="row">
        <div class="col-md-4">
          <div class="card mb-3">
            <div class="card-header">Contratos Totales</div>
            <div class="card-body">
              <strong>{{ dashboard.contratos_total }}</strong>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="card mb-3">
            <div class="card-header">Contratos Vigentes</div>
            <div class="card-body">
              <strong>{{ dashboard.contratos_vigentes }}</strong>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="card mb-3">
            <div class="card-header">Contratos Cancelados</div>
            <div class="card-body">
              <strong>{{ dashboard.contratos_cancelados }}</strong>
            </div>
          </div>
        </div>
      </div>
      <h3>Pagos por Operación</h3>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Operación</th>
            <th>Registros</th>
            <th>Importe</th>
            <th>Vigente</th>
            <th>Cancelado</th>
            <th>Pendiente</th>
            <th>Suspendido</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="op in dashboard.pagos" :key="op.operacion">
            <td>{{ op.operacion_nombre }}</td>
            <td>{{ op.registros }}</td>
            <td>{{ op.importe | currency }}</td>
            <td>{{ op.vigente }}</td>
            <td>{{ op.cancelado }}</td>
            <td>{{ op.pendiente }}</td>
            <td>{{ op.suspendido }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ProcesosAseoPage',
  data() {
    return {
      tiposAseo: [],
      selectedTipo: null,
      dashboard: null,
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') {
        return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
      }
      return val;
    }
  },
  created() {
    this.fetchTiposAseo();
  },
  methods: {
    async fetchTiposAseo() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation: 'get_tipo_aseo',
              params: { tipo: 0 }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.tiposAseo = data.eResponse.data;
          if (this.tiposAseo.length > 0) {
            this.selectedTipo = this.tiposAseo[0].ctrol_aseo;
            this.onTipoChange();
          }
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async onTipoChange() {
      if (!this.selectedTipo) return;
      this.loading = true;
      this.error = '';
      try {
        // Obtener fecha actual y calcular fechas corte1 y corte2 (simula lógica Delphi)
        const today = new Date();
        const year = today.getFullYear();
        const month = today.getMonth() + 1;
        const day = today.getDate();
        // Obtener día límite
        let diaLimite = 0;
        const resDia = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation: 'get_dia_limite',
              params: { mes: month }
            }
          })
        });
        const diaData = await resDia.json();
        if (diaData.eResponse.success && diaData.eResponse.data.length > 0) {
          diaLimite = diaData.eResponse.data[0].dia;
        }
        // Calcular fechas corte1 y corte2
        let fechaCorte1, fechaCorte2;
        if (day > diaLimite) {
          fechaCorte1 = new Date(year, month - 1, 1);
          if (month > 2) {
            fechaCorte2 = new Date(year, month - 3, 1);
          } else if (month === 2) {
            fechaCorte2 = new Date(year - 1, 11, 1);
          } else {
            fechaCorte2 = new Date(year - 1, 10, 1);
          }
        } else {
          if (month === 1) {
            fechaCorte1 = new Date(year - 1, 11, 1);
          } else {
            fechaCorte1 = new Date(year, month - 2, 1);
          }
          if (month > 3) {
            fechaCorte2 = new Date(year, month - 4, 1);
          } else if (month === 3) {
            fechaCorte2 = new Date(year - 1, 11, 1);
          } else if (month === 2) {
            fechaCorte2 = new Date(year - 1, 10, 1);
          } else {
            fechaCorte2 = new Date(year - 1, 9, 1);
          }
        }
        // Formatear fechas yyyy-mm
        const f1 = fechaCorte1.toISOString().slice(0, 7);
        const f2 = fechaCorte2.toISOString().slice(0, 7);
        // Llamar dashboard
        const resDash = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation: 'procesos_dashboard',
              params: {
                ctrol_a: this.selectedTipo,
                fecha1: f1,
                fecha2: f2
              }
            }
          })
        });
        const dashData = await resDash.json();
        if (dashData.eResponse.success) {
          this.dashboard = dashData.eResponse.data[0];
        } else {
          this.error = dashData.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.procesos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
</style>

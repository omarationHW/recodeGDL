<template>
  <div class="reportes-folios-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reportes Folios</li>
      </ol>
    </nav>
    <h1 class="mb-4">Reportes de Folios</h1>
    <form @submit.prevent="ejecutarReporte">
      <div class="row mb-3">
        <div class="col-md-4">
          <label for="tipoSolicitud" class="form-label">Tipo de Solicitud</label>
          <select v-model="form.tipo_solicitud" id="tipoSolicitud" class="form-select" @change="onTipoSolicitudChange">
            <option v-for="(label, idx) in tiposSolicitud" :key="idx" :value="idx+1">{{ label }}</option>
          </select>
        </div>
        <div class="col-md-4" v-if="showInfraccion">
          <label for="cveInfraccion" class="form-label">Clave Infracción</label>
          <select v-model="form.cve_infraccion" id="cveInfraccion" class="form-select">
            <option v-for="inf in infracciones" :key="inf.num_clave" :value="inf.num_clave">
              {{ inf.num_clave.toString().padStart(2, '0') }} - {{ inf.descripcion }}
            </option>
          </select>
        </div>
      </div>
      <div class="row mb-3">
        <div class="col-md-2">
          <label for="fechaInicio" class="form-label">Fecha Inicio</label>
          <input type="date" v-model="form.fecha_inicio" id="fechaInicio" class="form-control" required>
        </div>
        <div class="col-md-2">
          <label for="fechaFin" class="form-label">Fecha Fin</label>
          <input type="date" v-model="form.fecha_fin" id="fechaFin" class="form-control" required>
        </div>
      </div>
      <div class="mb-3">
        <button type="submit" class="btn btn-primary me-2">Ejecutar</button>
        <button type="button" class="btn btn-secondary" @click="resetForm">Cancelar</button>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reporte.length > 0">
      <h3 class="mt-4">Resultado</h3>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th v-for="col in reporteColumns" :key="col">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in reporte" :key="idx">
              <td v-for="col in reporteColumns" :key="col">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReportesFoliosPage',
  data() {
    return {
      tiposSolicitud: [
        '01 .- Folios de Adeudos',
        '02 .- Folios Pagados',
        '03 .- Folios Cancelados',
        '04 .- Folios Condonados',
        '05 .- Folios Cancelados y Condonados',
        '06 .- Relación de Descuentos Otorgados'
      ],
      infracciones: [],
      form: {
        tipo_solicitud: 1,
        cve_infraccion: 0,
        fecha_inicio: '',
        fecha_fin: ''
      },
      reporte: [],
      reporteColumns: [],
      loading: false,
      error: ''
    };
  },
  computed: {
    showInfraccion() {
      // Oculta infracción si tipo_solicitud == 6
      return this.form.tipo_solicitud !== 6;
    }
  },
  created() {
    this.fetchInfracciones();
    const today = new Date().toISOString().substr(0, 10);
    this.form.fecha_inicio = today;
    this.form.fecha_fin = today;
  },
  methods: {
    async fetchInfracciones() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action: 'getInfracciones' }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.infracciones = [{ num_clave: 0, descripcion: 'Todos' }, ...data.eResponse.data];
          this.form.cve_infraccion = 0;
        } else {
          this.error = data.eResponse.message || 'Error al cargar infracciones';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    onTipoSolicitudChange() {
      // Si cambia a tipo 6, oculta infracción
      if (!this.showInfraccion) {
        this.form.cve_infraccion = 0;
      }
    },
    async ejecutarReporte() {
      this.loading = true;
      this.error = '';
      this.reporte = [];
      this.reporteColumns = [];
      try {
        const params = {
          cve_infraccion: this.form.cve_infraccion,
          tipo_solicitud: this.form.tipo_solicitud,
          fecha_inicio: this.form.fecha_inicio,
          fecha_fin: this.form.fecha_fin
        };
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getReportesFolios',
              params
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.reporte = data.eResponse.data;
          if (this.reporte.length > 0) {
            this.reporteColumns = Object.keys(this.reporte[0]);
          }
        } else {
          this.error = data.eResponse.message || 'Error al ejecutar reporte';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    resetForm() {
      this.form.tipo_solicitud = 1;
      this.form.cve_infraccion = 0;
      const today = new Date().toISOString().substr(0, 10);
      this.form.fecha_inicio = today;
      this.form.fecha_fin = today;
      this.reporte = [];
      this.reporteColumns = [];
      this.error = '';
    }
  }
};
</script>

<style scoped>
.reportes-folios-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
</style>

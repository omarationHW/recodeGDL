<template>
  <div class="container py-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Contratos</li>
      </ol>
    </nav>
    <h2 class="mb-4">Padron de Contratos</h2>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row g-3">
        <div class="col-md-2">
          <label class="form-label">Selección</label>
          <select v-model.number="form.seleccion" class="form-select">
            <option :value="1">Todos</option>
            <option :value="2">Por Empresa</option>
          </select>
        </div>
        <div class="col-md-2">
          <label class="form-label">Empresa (Num_emp)</label>
          <input type="number" v-model.number="form.Num_emp" class="form-control" :disabled="form.seleccion !== 2">
        </div>
        <div class="col-md-2">
          <label class="form-label">Ofna (Recaudadora)</label>
          <input type="number" v-model.number="form.Ofna" class="form-control">
        </div>
        <div class="col-md-2">
          <label class="form-label">Tipo de Aseo (Ctrol_Aseo)</label>
          <input type="number" v-model.number="form.Ctrol_Aseo" class="form-control">
        </div>
        <div class="col-md-2">
          <label class="form-label">Vigencia</label>
          <select v-model="form.Vigencia" class="form-select">
            <option value="T">Todos</option>
            <option value="V">Vigente</option>
            <option value="C">Cancelado</option>
          </select>
        </div>
        <div class="col-md-2">
          <label class="form-label">Clasificación</label>
          <select v-model.number="form.opcion" class="form-select">
            <option :value="1">Numero de Control</option>
            <option :value="2">Numero de Contrato</option>
            <option :value="3">Tipo de Aseo</option>
            <option :value="4">Recaudadora</option>
            <option :value="5">Tipo de Recolección</option>
            <option :value="6">Vigencia</option>
            <option :value="7">Fecha de Obligación</option>
            <option :value="8">Domicilio</option>
          </select>
        </div>
      </div>
      <div class="mt-3">
        <button type="submit" class="btn btn-primary">Generar Reporte</button>
      </div>
    </form>

    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>

    <div v-if="reportData">
      <div class="mb-3">
        <strong>Total de Contratos:</strong> {{ reportData.totales.total }} |
        <strong>Vigentes:</strong> {{ reportData.totales.vigentes }} |
        <strong>Cancelados:</strong> {{ reportData.totales.cancelados }}
      </div>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead class="table-light">
            <tr>
              <th>No. de Emp</th>
              <th>Tipo de Empresa</th>
              <th>Nombre de la Empresa</th>
              <th>Representante</th>
              <th>No. Contrato</th>
              <th>Tipo de Aseo</th>
              <th>Recolección</th>
              <th>Cant.</th>
              <th>Domicilio</th>
              <th>Sector</th>
              <th>Zona</th>
              <th>SubZona</th>
              <th>Rec.</th>
              <th>Alta</th>
              <th>Fec-Baja</th>
              <th>Vigencia</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="contrato in reportData.contratos" :key="contrato.control_contrato">
              <td>{{ contrato.num_empresa }}</td>
              <td>{{ contrato.tipo_empresa }}</td>
              <td>{{ contrato.descripcion_1 }}</td>
              <td>{{ contrato.representante }}</td>
              <td>{{ contrato.num_contrato }}</td>
              <td>{{ contrato.descripcion_2 }}</td>
              <td>{{ contrato.descripcion_3 }}</td>
              <td>{{ contrato.cantidad_recolec }}</td>
              <td>{{ contrato.domicilio }}</td>
              <td>{{ contrato.sector }}</td>
              <td>{{ contrato.zona }}</td>
              <td>{{ contrato.sub_zona }}</td>
              <td>{{ contrato.id_rec }}</td>
              <td>{{ formatDate(contrato.aso_mes_oblig) }}</td>
              <td>{{ formatDate(contrato.fecha_hora_baja) }}</td>
              <td>
                <span v-if="contrato.status_vigencia === 'V'" class="badge bg-success">VIGENTE</span>
                <span v-else-if="contrato.status_vigencia === 'C'" class="badge bg-danger">CANCELADO</span>
                <span v-else class="badge bg-secondary">{{ contrato.status_vigencia }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptContratosPage',
  data() {
    return {
      form: {
        seleccion: 1,
        Ofna: 0,
        Rep: 0,
        opcion: 1,
        Num_emp: 0,
        Ctrol_Aseo: 0,
        Vigencia: 'T'
      },
      loading: false,
      error: '',
      reportData: null
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'RptContratos',
            params: this.form
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.reportData = data.eResponse.data;
        } else {
          this.error = data.eResponse && data.eResponse.message ? data.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = 'Error de red o del servidor';
      } finally {
        this.loading = false;
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      if (isNaN(d)) return dateStr;
      return d.toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.table th, .table td {
  font-size: 0.95em;
}
</style>

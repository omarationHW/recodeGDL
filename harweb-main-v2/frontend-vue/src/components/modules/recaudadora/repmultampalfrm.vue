<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reportes de Multas Municipales</li>
      </ol>
    </nav>
    <h2 class="mb-3">Reportes de Multas Municipales</h2>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-4">
              <label class="form-label">Estado</label>
              <select v-model="form.estatus" class="form-select">
                <option :value="0">Todos</option>
                <option :value="1">Vigente</option>
                <option :value="2">Pagado</option>
                <option :value="3">Cancelado</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Fecha</label>
              <select v-model="form.fecha_tipo" class="form-select" @change="onFechaTipoChange">
                <option :value="0">Todos</option>
                <option :value="1">Fecha</option>
                <option :value="2">Rango de fechas</option>
                <option :value="3">Año</option>
              </select>
            </div>
          </div>
          <div class="row mb-3" v-if="form.fecha_tipo === 1">
            <div class="col-md-4">
              <label class="form-label">Fecha</label>
              <input type="date" v-model="form.fecha1" class="form-control" required>
            </div>
          </div>
          <div class="row mb-3" v-if="form.fecha_tipo === 2">
            <div class="col-md-4">
              <label class="form-label">Fecha inicio</label>
              <input type="date" v-model="form.fecha1" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">Fecha fin</label>
              <input type="date" v-model="form.fecha2" class="form-control" required>
            </div>
          </div>
          <div class="row mb-3" v-if="form.fecha_tipo === 3">
            <div class="col-md-4">
              <label class="form-label">Año</label>
              <input type="number" v-model="form.anio" class="form-control" min="1900" max="2100" required>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-4">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" v-model="form.filtro_dependencia" id="chkDependencia">
                <label class="form-check-label" for="chkDependencia">Dependencia</label>
              </div>
              <select v-model="form.id_dependencia" class="form-select mt-2" :disabled="!form.filtro_dependencia" @change="onDependenciaChange">
                <option :value="null">Seleccione dependencia</option>
                <option v-for="dep in dependencias" :key="dep.id_dependencia" :value="dep.id_dependencia">{{ dep.descripcion }}</option>
              </select>
            </div>
            <div class="col-md-4">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" v-model="form.filtro_infraccion" id="chkInfraccion">
                <label class="form-check-label" for="chkInfraccion">Infracción</label>
              </div>
              <select v-model="form.id_infraccion" class="form-select mt-2" :disabled="!form.filtro_infraccion">
                <option :value="null">Seleccione infracción</option>
                <option v-for="inf in infracciones" :key="inf.id_infraccion" :value="inf.id_infraccion">{{ inf.descripcion }}</option>
              </select>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-4">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" v-model="form.filtro_contribuyente" id="chkContribuyente">
                <label class="form-check-label" for="chkContribuyente">Nombre</label>
              </div>
              <input type="text" v-model="form.contribuyente" class="form-control mt-2" :disabled="!form.filtro_contribuyente" placeholder="Nombre contribuyente">
            </div>
            <div class="col-md-4">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" v-model="form.filtro_domicilio" id="chkDomicilio">
                <label class="form-check-label" for="chkDomicilio">Domicilio</label>
              </div>
              <input type="text" v-model="form.domicilio" class="form-control mt-2" :disabled="!form.filtro_domicilio" placeholder="Domicilio">
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-12">
              <button type="submit" class="btn btn-primary">Imprimir / Consultar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="resultados && resultados.length">
      <h4>Resultados ({{ resultados.length }})</h4>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th>Dep.</th>
              <th>Año</th>
              <th>No. acta</th>
              <th>Fecha</th>
              <th>Nombre</th>
              <th>Domicilio</th>
              <th>Calificación</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in resultados" :key="row.id_multa">
              <td>{{ row.dependencia }}</td>
              <td>{{ row.axo_acta }}</td>
              <td>{{ row.num_acta }}</td>
              <td>{{ row.fecha_acta ? row.fecha_acta.substr(0,10) : '' }}</td>
              <td>{{ row.contribuyente }}</td>
              <td>{{ row.domicilio }}</td>
              <td class="text-end">{{ row.calificacion }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="mt-2">
        <strong>Total de registros: {{ resultados.length }}</strong>
      </div>
    </div>
    <div v-else-if="resultados && !resultados.length">
      <div class="alert alert-warning">No se encontraron resultados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReporteMultasMunicipales',
  data() {
    return {
      dependencias: [],
      infracciones: [],
      resultados: null,
      loading: false,
      error: '',
      form: {
        estatus: 0,
        fecha_tipo: 0,
        fecha1: '',
        fecha2: '',
        anio: '',
        filtro_dependencia: false,
        id_dependencia: null,
        filtro_infraccion: false,
        id_infraccion: null,
        filtro_contribuyente: false,
        contribuyente: '',
        filtro_domicilio: false,
        domicilio: ''
      }
    }
  },
  watch: {
    'form.id_dependencia'(val) {
      if (val && this.form.filtro_infraccion) {
        this.loadInfracciones(val);
      } else {
        this.infracciones = [];
        this.form.id_infraccion = null;
      }
    },
    'form.filtro_infraccion'(val) {
      if (val && this.form.id_dependencia) {
        this.loadInfracciones(this.form.id_dependencia);
      } else {
        this.infracciones = [];
        this.form.id_infraccion = null;
      }
    }
  },
  mounted() {
    this.loadDependencias();
  },
  methods: {
    async loadDependencias() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'get_dependencias' })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.dependencias = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error al cargar dependencias';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async loadInfracciones(id_dependencia) {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'get_infracciones_by_dependencia', params: { id_dependencia } })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.infracciones = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error al cargar infracciones';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    onFechaTipoChange() {
      this.form.fecha1 = '';
      this.form.fecha2 = '';
      this.form.anio = '';
    },
    onDependenciaChange() {
      if (!this.form.id_dependencia) {
        this.infracciones = [];
        this.form.id_infraccion = null;
      }
    },
    async onSubmit() {
      this.error = '';
      this.resultados = null;
      // Validaciones
      if (this.form.fecha_tipo === 1 && !this.form.fecha1) {
        this.error = 'Seleccione la fecha.';
        return;
      }
      if (this.form.fecha_tipo === 2 && (!this.form.fecha1 || !this.form.fecha2)) {
        this.error = 'Debe seleccionar fecha de inicio y fin.';
        return;
      }
      if (this.form.fecha_tipo === 3 && (!this.form.anio || this.form.anio < 1900)) {
        this.error = 'Debe especificar el año.';
        return;
      }
      // Armar parámetros
      const params = {
        id_dependencia: this.form.filtro_dependencia ? this.form.id_dependencia : null,
        id_infraccion: this.form.filtro_infraccion ? this.form.id_infraccion : null,
        contribuyente: this.form.filtro_contribuyente ? this.form.contribuyente : null,
        domicilio: this.form.filtro_domicilio ? this.form.domicilio : null,
        fecha_tipo: this.form.fecha_tipo,
        fecha1: this.form.fecha1,
        fecha2: this.form.fecha2,
        anio: this.form.anio,
        estatus: this.form.estatus
      };
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'get_multas_report', params })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.resultados = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error al consultar.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.table th, .table td {
  vertical-align: middle;
}
</style>

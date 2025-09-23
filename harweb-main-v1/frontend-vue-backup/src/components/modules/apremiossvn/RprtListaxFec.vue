<template>
  <div class="rprt-listaxfec-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado por Fechas</li>
      </ol>
    </nav>
    <h1>Listado de Requerimientos por Fecha</h1>
    <form @submit.prevent="fetchReport">
      <div class="row">
        <div class="col-md-2">
          <label>Recaudadora (Zona)</label>
          <input v-model.number="form.vrec" type="number" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Módulo</label>
          <select v-model.number="form.vmod" class="form-control" required>
            <option :value="11">Mercados</option>
            <option :value="16">Aseo</option>
            <option :value="24">Estacionamientos Públicos</option>
            <option :value="28">Estacionamientos Exclusivos</option>
            <option :value="14">Estacionómetros</option>
            <option :value="13">Cementerios</option>
            <option :value="99">Todos</option>
          </select>
        </div>
        <div class="col-md-2">
          <label>Tipo de Fecha</label>
          <select v-model.number="form.vcve" class="form-control" required>
            <option :value="1">Fecha Actualización</option>
            <option :value="2">Fecha Practicado</option>
            <option :value="3">Fecha Citatorio</option>
            <option :value="4">Fecha Pago</option>
            <option :value="5">Fecha Emisión</option>
            <option :value="6">Fecha Entrega</option>
          </select>
        </div>
        <div class="col-md-2">
          <label>Fecha Inicial</label>
          <input v-model="form.vfec1" type="date" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Fecha Final</label>
          <input v-model="form.vfec2" type="date" class="form-control" required />
        </div>
        <div class="col-md-1">
          <label>Vigencia</label>
          <select v-model="form.vvig" class="form-control" required>
            <option value="todas">Todas</option>
            <option value="1">Vigente</option>
            <option value="2">Vencida</option>
            <option value="P">Pendiente</option>
          </select>
        </div>
        <div class="col-md-1">
          <label>Ejecutor</label>
          <input v-model="form.veje" type="text" class="form-control" placeholder="todos/ninguno/o id" />
        </div>
      </div>
      <div class="mt-3">
        <button type="submit" class="btn btn-primary">Buscar</button>
      </div>
    </form>
    <div v-if="loading" class="mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="report.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm table-hover">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Fecha Emisión</th>
            <th>Clave Practicado</th>
            <th>Fecha Practicado</th>
            <th>Hora</th>
            <th>Ejecutor</th>
            <th>Fecha Entrega</th>
            <th>Nombre</th>
            <th>Fecha Pago</th>
            <th>Recaudadora</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Vigencia</th>
            <th>Datos</th>
            <th>Zona</th>
            <th>Fecha Citatorio</th>
            <th>Importe Global</th>
            <th>Importe Recargo</th>
            <th>Importe Multa</th>
            <th>Importe Gastos</th>
            <th>Porcentaje Multa</th>
            <th>Importe Pago</th>
            <th>Observaciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.folio">
            <td>{{ row.folio }}</td>
            <td>{{ row.fecha_emision }}</td>
            <td>{{ row.clave_practicado }}</td>
            <td>{{ row.fecha_practicado }}</td>
            <td>{{ row.hora }}</td>
            <td>{{ row.ejecutor }}</td>
            <td>{{ row.fecha_entrega1 }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.fecha_pago }}</td>
            <td>{{ row.recaudadora }}</td>
            <td>{{ row.caja }}</td>
            <td>{{ row.operacion }}</td>
            <td>{{ row.vigencia }}</td>
            <td>{{ row.datos }}</td>
            <td>{{ row.zona }}</td>
            <td>{{ row.fecha_citatorio }}</td>
            <td>{{ row.importe_global }}</td>
            <td>{{ row.importe_recargo }}</td>
            <td>{{ row.importe_multa }}</td>
            <td>{{ row.importe_gastos }}</td>
            <td>{{ row.porcentaje_multa }}</td>
            <td>{{ row.importe_pago }}</td>
            <td>{{ row.observaciones }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total registros:</strong> {{ report.length }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RprtListaxFecPage',
  data() {
    return {
      form: {
        vrec: '',
        vmod: 11,
        vcve: 1,
        vfec1: '',
        vfec2: '',
        vvig: 'todas',
        veje: 'todos'
      },
      report: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'rprt_listaxfec',
            params: this.form
          })
        });
        const data = await response.json();
        if (data.success) {
          this.report = data.data;
        } else {
          this.error = data.message || 'Error al obtener datos';
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
.rprt-listaxfec-page {
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>

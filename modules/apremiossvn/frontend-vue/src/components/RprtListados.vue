<template>
  <div class="rprt-listados-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Requerimientos</li>
      </ol>
    </nav>
    <h1>Listado de Requerimientos</h1>
    <form @submit.prevent="fetchReport">
      <div class="row">
        <div class="col-md-2">
          <label>Zona/Oficina (vrec)</label>
          <input v-model.number="form.vrec" type="number" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Módulo (vmod)</label>
          <select v-model.number="form.vmod" class="form-control" required>
            <option :value="11">Mercados</option>
            <option :value="16">Aseo</option>
            <option :value="24">Estacionamientos Públicos</option>
            <option :value="28">Estacionamientos Exclusivos</option>
            <option :value="14">Estacionómetros</option>
            <option :value="13">Cementerios</option>
          </select>
        </div>
        <div class="col-md-2">
          <label>Folio Inicial (vfol1)</label>
          <input v-model.number="form.vfol1" type="number" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Folio Final (vfol2)</label>
          <input v-model.number="form.vfol2" type="number" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Clave Practicado (vcve)</label>
          <select v-model="form.vcve" class="form-control">
            <option value="todas">Todas</option>
            <option value="P">P</option>
            <option value="O">O</option>
            <option value="X">X</option>
          </select>
        </div>
        <div class="col-md-2">
          <label>Vigencia (vvig)</label>
          <select v-model="form.vvig" class="form-control">
            <option value="todas">Todas</option>
            <option value="1">Vig</option>
            <option value="2">Pag</option>
            <option value="3">Can</option>
            <option value="P">Sus</option>
          </select>
        </div>
      </div>
      <div class="row mt-2" v-if="form.vcve === 'P'">
        <div class="col-md-3">
          <label>Fecha Desde (vfdsd)</label>
          <input v-model="form.vfdsd" type="date" class="form-control" />
        </div>
        <div class="col-md-3">
          <label>Fecha Hasta (vfhst)</label>
          <input v-model="form.vfhst" type="date" class="form-control" />
        </div>
      </div>
      <div class="mt-3">
        <button type="submit" class="btn btn-primary">Consultar</button>
      </div>
    </form>
    <div v-if="loading" class="mt-4">
      <span>Cargando...</span>
    </div>
    <div v-if="error" class="alert alert-danger mt-4">{{ error }}</div>
    <div v-if="report.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
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
            <th>Datos</th>
            <th>Vigencia</th>
            <th>Importe Global</th>
            <th>Importe Multa</th>
            <th>Importe Recargo</th>
            <th>Importe Gastos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_control">
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
            <td>{{ row.datos }}</td>
            <td>{{ row.vigencia }}</td>
            <td>{{ row.importe_global }}</td>
            <td>{{ row.importe_multa }}</td>
            <td>{{ row.importe_recargo }}</td>
            <td>{{ row.importe_gastos }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total registros:</strong> {{ report.length }}
      </div>
      <div class="mt-2">
        <strong>Suma Importe Global:</strong> {{ sum('importe_global') }}<br>
        <strong>Suma Multa:</strong> {{ sum('importe_multa') }}<br>
        <strong>Suma Recargo:</strong> {{ sum('importe_recargo') }}<br>
        <strong>Suma Gastos:</strong> {{ sum('importe_gastos') }}<br>
        <strong>Total General:</strong> {{ sumTotalGeneral() }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RprtListadosPage',
  data() {
    return {
      form: {
        vrec: '',
        vmod: 11,
        vfol1: '',
        vfol2: '',
        vcve: 'todas',
        vvig: 'todas',
        vfdsd: '',
        vfhst: ''
      },
      loading: false,
      error: '',
      report: []
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const params = { ...this.form };
        // Only send vfdsd/vfhst if vcve == 'P'
        if (params.vcve !== 'P') {
          params.vfdsd = null;
          params.vfhst = null;
        }
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'getRprtListados',
            params
          })
        });
        const data = await response.json();
        if (data.success) {
          this.report = data.data;
        } else {
          this.error = data.message || 'Error al consultar el reporte';
        }
      } catch (err) {
        this.error = err.message || 'Error inesperado';
      } finally {
        this.loading = false;
      }
    },
    sum(field) {
      return this.report.reduce((acc, row) => acc + (parseFloat(row[field]) || 0), 0).toFixed(2);
    },
    sumTotalGeneral() {
      return this.report.reduce((acc, row) => {
        return acc +
          (parseFloat(row.importe_global) || 0) +
          (parseFloat(row.importe_multa) || 0) +
          (parseFloat(row.importe_recargo) || 0) +
          (parseFloat(row.importe_gastos) || 0);
      }, 0).toFixed(2);
    }
  }
};
</script>

<style scoped>
.rprt-listados-page {
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>

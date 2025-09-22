<template>
  <div class="rprt-listaxreg-estacionometro">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado x Reg. Estacionómetro</li>
      </ol>
    </nav>
    <h2>Listado de Registros de Estacionómetros con Requerimientos</h2>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="vigencia">Vigencia</label>
          <select v-model="form.vigencia" id="vigencia" class="form-control">
            <option value="todas">Todas</option>
            <option value="1">Vigente</option>
            <option value="2">Pagado</option>
            <option value="3">Cancelado</option>
            <option value="P">Pendiente</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label for="clave_practicado">Clave Practicado</label>
          <input v-model="form.clave_practicado" id="clave_practicado" class="form-control" placeholder="Clave o 'todas'">
        </div>
        <div class="form-group col-md-3">
          <label for="colonia">Colonia</label>
          <input v-model="form.colonia" id="colonia" class="form-control" required>
        </div>
        <div class="form-group col-md-3">
          <label for="oficina">Oficina</label>
          <input v-model="form.oficina" id="oficina" class="form-control" type="number" min="1">
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Buscar</button>
    </form>

    <div v-if="loading" class="mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>

    <div v-if="report.length" class="table-responsive mt-4">
      <table class="table table-bordered table-sm">
        <thead class="thead-light">
          <tr>
            <th>Folio</th>
            <th>Placa</th>
            <th>Colonia</th>
            <th>Fecha Emisión</th>
            <th>Clave Practicado</th>
            <th>Fecha Practicado</th>
            <th>Ejecutor</th>
            <th>Nombre</th>
            <th>Importe Global</th>
            <th>Importe Multa</th>
            <th>Importe Recargo</th>
            <th>Importe Gastos</th>
            <th>Porcentaje Multa</th>
            <th>Fecha Pago</th>
            <th>Recaudadora</th>
            <th>Caja</th>
            <th>Operacion</th>
            <th>Importe Pago</th>
            <th>Vigencia</th>
            <th>Observaciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id">
            <td>{{ row.folio }}</td>
            <td>{{ row.placa }}</td>
            <td>{{ row.colonia }}</td>
            <td>{{ row.fecha_emision }}</td>
            <td>{{ row.clave_practicado }}</td>
            <td>{{ row.fecha_practicado }}</td>
            <td>{{ row.ejecutor }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.importe_global | currency }}</td>
            <td>{{ row.importe_multa | currency }}</td>
            <td>{{ row.importe_recargo | currency }}</td>
            <td>{{ row.importe_gastos | currency }}</td>
            <td>{{ row.porcentaje_multa }}%</td>
            <td>{{ row.fecha_pago }}</td>
            <td>{{ row.recaudadora }}</td>
            <td>{{ row.caja }}</td>
            <td>{{ row.operacion }}</td>
            <td>{{ row.importe_pago | currency }}</td>
            <td>{{ vigenciaLabel(row.vigencia_1) }}</td>
            <td>{{ row.observaciones }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total registros:</strong> {{ report.length }}
      </div>
      <div class="mt-3">
        <strong>Totales:</strong>
        <ul>
          <li>Importe Global: {{ total('importe_global') | currency }}</li>
          <li>Importe Multa: {{ total('importe_multa') | currency }}</li>
          <li>Importe Recargo: {{ total('importe_recargo') | currency }}</li>
          <li>Importe Gastos: {{ total('importe_gastos') | currency }}</li>
          <li>Importe General: {{ totalGeneral | currency }}</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RprtListaxRegEstacionometro',
  data() {
    return {
      form: {
        vigencia: 'todas',
        clave_practicado: 'todas',
        colonia: '',
        oficina: null
      },
      report: [],
      loading: false,
      error: ''
    };
  },
  computed: {
    totalGeneral() {
      return (
        this.total('importe_global') +
        this.total('importe_multa') +
        this.total('importe_recargo') +
        this.total('importe_gastos')
      );
    }
  },
  methods: {
    fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          action: 'getEstacionometroReport',
          params: {
            vigencia: this.form.vigencia,
            clave_practicado: this.form.clave_practicado,
            colonia: this.form.colonia,
            oficina: this.form.oficina
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.success) {
            this.report = json.data;
          } else {
            this.error = json.message || 'Error al obtener datos';
          }
        })
        .catch(err => {
          this.error = err.message || 'Error de red';
        })
        .finally(() => {
          this.loading = false;
        });
    },
    total(field) {
      return this.report.reduce((sum, row) => sum + (parseFloat(row[field]) || 0), 0);
    },
    vigenciaLabel(vig) {
      if (vig === '3') return 'CANCELADO';
      if (vig === '1') return 'VIGENTE';
      if (vig === '2') return 'PAGADO';
      if (vig === 'P') return 'PENDIENTE';
      return vig;
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
.rprt-listaxreg-estacionometro {
  max-width: 100%;
  padding: 2rem;
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>

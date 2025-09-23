<template>
  <div class="contrarecibos-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Contrarecibos</li>
      </ol>
    </nav>
    <h1>Gestión de Contrarecibos</h1>
    <div class="mb-3">
      <label for="fecha" class="form-label">Fecha de Ingreso</label>
      <input type="date" v-model="fecha" id="fecha" class="form-control" />
      <button class="btn btn-primary mt-2" @click="buscar">Buscar</button>
    </div>
    <div v-if="contrarecibos.length">
      <h2>Listado de Contrarecibos</h2>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Ejercicio</th>
            <th>Procedencia</th>
            <th>Contrarecibo</th>
            <th>Proveedor</th>
            <th>Importe</th>
            <th>Fecha Contrarecibo</th>
            <th>Concepto</th>
            <th>Notas</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="crbo in contrarecibos" :key="crbo.contrarecibo">
            <td>{{ crbo.ejercicio }}</td>
            <td>{{ crbo.procedencia }}</td>
            <td>{{ crbo.contrarecibo }}</td>
            <td>{{ crbo.denominacion }}</td>
            <td>{{ crbo.importe | currency }}</td>
            <td>{{ crbo.fecha_contrarecibo }}</td>
            <td>{{ crbo.concepto }}</td>
            <td>{{ crbo.notas }}</td>
            <td>
              <button class="btn btn-sm btn-info" @click="verDetalle(crbo.contrarecibo)">Detalle</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="alert alert-info">
        <strong>Total del día:</strong> {{ total | currency }}
      </div>
    </div>
    <div v-if="detalle">
      <h2>Detalle de Contrarecibo #{{ detalle.contrarecibo }}</h2>
      <ul class="list-group mb-3">
        <li class="list-group-item"><strong>Proveedor:</strong> {{ detalle.id_proveedor }}</li>
        <li class="list-group-item"><strong>Importe:</strong> {{ detalle.importe | currency }}</li>
        <li class="list-group-item"><strong>Concepto:</strong> {{ detalle.concepto }}</li>
        <li class="list-group-item"><strong>Notas:</strong> {{ detalle.notas }}</li>
        <li class="list-group-item"><strong>Estado:</strong> {{ calcularEstado(detalle) }}</li>
      </ul>
      <button class="btn btn-secondary" @click="detalle = null">Cerrar Detalle</button>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ContrarecibosPage',
  data() {
    return {
      fecha: '',
      contrarecibos: [],
      total: 0,
      detalle: null,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  },
  methods: {
    async buscar() {
      this.error = '';
      this.detalle = null;
      if (!this.fecha) {
        this.error = 'Seleccione una fecha.';
        return;
      }
      try {
        // Obtener listado
        let res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.getContrarecibosByDate',
          payload: { fecha: this.fecha }
        });
        if (res.data.status === 'success') {
          this.contrarecibos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar.';
        }
        // Obtener total
        let res2 = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.sumContrarecibosByDate',
          payload: { fecha: this.fecha }
        });
        if (res2.data.status === 'success') {
          this.total = res2.data.data.total || 0;
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      }
    },
    async verDetalle(contrarecibo) {
      this.error = '';
      try {
        let res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.getContrareciboDetalle',
          payload: { contrarecibo }
        });
        if (res.data.status === 'success') {
          this.detalle = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar detalle.';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      }
    },
    calcularEstado(det) {
      if (!det) return '';
      if (det.fecha_cancenlacion) return 'CANCELADO';
      if (det.num_ctrol_cheque && det.num_ctrol_cheque > 0) return 'Con Cheque';
      if (det.fecha_tramite_caja) return 'En Caja';
      if (det.fecha_programacion) return 'Programacion';
      if (det.fecha_verificacion) return 'Verificacion';
      if (det.fecha_codificacion) return 'Presupuestos';
      return 'Ingreso';
    }
  }
};
</script>

<style scoped>
.contrarecibos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>

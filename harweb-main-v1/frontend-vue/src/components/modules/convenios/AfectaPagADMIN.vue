<template>
  <div class="afecta-pag-admin-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Afecta Pagos ADMIN</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header">Afectar Pagos de Convenios Diversos</div>
      <div class="card-body">
        <form @submit.prevent="consultarPagos">
          <div class="form-group row">
            <label class="col-sm-2 col-form-label">Fecha de Pago a Afectar:</label>
            <div class="col-sm-3">
              <input type="date" v-model="fecha" class="form-control" required />
            </div>
            <div class="col-sm-2">
              <button type="submit" class="btn btn-primary">Consultar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="pagos.length" class="card mb-3">
      <div class="card-header">Pagos Encontrados</div>
      <div class="card-body p-0">
        <table class="table table-sm table-bordered table-hover mb-0">
          <thead class="thead-light">
            <tr>
              <th>ID Convenio</th>
              <th>Parcialidad</th>
              <th>Total Parc.</th>
              <th>Importe</th>
              <th>Recargos</th>
              <th>Intereses</th>
              <th>Fecha</th>
              <th>Estado</th>
              <th>Usuario</th>
              <th>Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in pagos" :key="p.id_recibo">
              <td>{{ p.id_convenio }}</td>
              <td>{{ p.parcialidad }}</td>
              <td>{{ p.total_parc }}</td>
              <td>{{ p.imp_parcialidad | currency }}</td>
              <td>{{ p.rec_parcialidad | currency }}</td>
              <td>{{ p.intereses | currency }}</td>
              <td>{{ p.fecha }}</td>
              <td>
                <span :class="{'badge badge-success': p.estado==='V', 'badge badge-danger': p.estado==='C'}">
                  {{ p.estado==='V' ? 'Vigente' : 'Cancelado' }}
                </span>
              </td>
              <td>{{ p.usuario }}</td>
              <td>
                <button v-if="p.estado==='V'" class="btn btn-sm btn-success" @click="afectarPago(p)">Afectar</button>
                <button v-if="p.estado==='C'" class="btn btn-sm btn-warning" @click="cancelarPago(p)">Cancelar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="card-footer text-right">
        <button class="btn btn-secondary" @click="$router.push('/')">Salir</button>
      </div>
    </div>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Procesando...
    </div>
    <div v-if="mensaje" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'AfectaPagAdminPage',
  data() {
    return {
      fecha: '',
      pagos: [],
      loading: false,
      mensaje: '',
      success: false
    };
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', {minimumFractionDigits: 2});
    }
  },
  methods: {
    async consultarPagos() {
      this.loading = true;
      this.mensaje = '';
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'listar',
            fecha: this.fecha
          }
        });
        if (resp.data.eResponse.success) {
          this.pagos = resp.data.eResponse.data;
        } else {
          this.mensaje = resp.data.eResponse.message;
          this.success = false;
        }
      } catch (e) {
        this.mensaje = 'Error de comunicación con el servidor';
        this.success = false;
      }
      this.loading = false;
    },
    async afectarPago(pago) {
      if (!confirm('¿Está seguro de afectar este pago?')) return;
      this.loading = true;
      this.mensaje = '';
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'afectar',
            fecha: this.fecha,
            usuario: this.$store.state.usuario
          }
        });
        if (resp.data.eResponse.success) {
          this.mensaje = 'Pagos afectados correctamente';
          this.success = true;
          this.consultarPagos();
        } else {
          this.mensaje = resp.data.eResponse.message;
          this.success = false;
        }
      } catch (e) {
        this.mensaje = 'Error al afectar pagos';
        this.success = false;
      }
      this.loading = false;
    },
    async cancelarPago(pago) {
      if (!confirm('¿Está seguro de cancelar este pago?')) return;
      this.loading = true;
      this.mensaje = '';
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'cancelar',
            id_pago: pago.id_recibo,
            usuario: this.$store.state.usuario
          }
        });
        if (resp.data.eResponse.success) {
          this.mensaje = 'Pago cancelado correctamente';
          this.success = true;
          this.consultarPagos();
        } else {
          this.mensaje = resp.data.eResponse.message;
          this.success = false;
        }
      } catch (e) {
        this.mensaje = 'Error al cancelar pago';
        this.success = false;
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.afecta-pag-admin-page {
  max-width: 1100px;
  margin: 0 auto;
}
</style>

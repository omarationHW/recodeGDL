<template>
  <div class="container">
    <h1>Gestión de Abstención de Movimientos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Abstención de Movimientos</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header">Buscar Abstenciones</div>
      <div class="card-body">
        <form @submit.prevent="buscarAbstenciones">
          <div class="row">
            <div class="col-md-4">
              <label for="cvecuenta">Clave de Cuenta</label>
              <input v-model="filtro.cvecuenta" type="number" class="form-control" id="cvecuenta" placeholder="Clave de cuenta" />
            </div>
            <div class="col-md-2 align-self-end">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="card mb-3">
      <div class="card-header">Agregar Abstención</div>
      <div class="card-body">
        <form @submit.prevent="agregarAbstencion">
          <div class="row">
            <div class="col-md-2">
              <label for="add_cvecuenta">Cuenta</label>
              <input v-model="form.cvecuenta" type="number" class="form-control" id="add_cvecuenta" required />
            </div>
            <div class="col-md-2">
              <label for="add_anio">Año</label>
              <input v-model="form.anio" type="number" class="form-control" id="add_anio" required />
            </div>
            <div class="col-md-2">
              <label for="add_bimestre">Bimestre</label>
              <input v-model="form.bimestre" type="number" min="1" max="6" class="form-control" id="add_bimestre" required />
            </div>
            <div class="col-md-4">
              <label for="add_observacion">Observación</label>
              <input v-model="form.observacion" type="text" class="form-control" id="add_observacion" />
            </div>
            <div class="col-md-2 align-self-end">
              <button type="submit" class="btn btn-success">Agregar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="card">
      <div class="card-header">Listado de Abstenciones</div>
      <div class="card-body">
        <table class="table table-bordered table-hover">
          <thead>
            <tr>
              <th>Cuenta</th>
              <th>Año</th>
              <th>Bimestre</th>
              <th>Observación</th>
              <th>Usuario</th>
              <th>Fecha</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="abs in abstenciones" :key="abs.id">
              <td>{{ abs.cvecuenta }}</td>
              <td>{{ abs.anio }}</td>
              <td>{{ abs.bimestre }}</td>
              <td>{{ abs.observacion }}</td>
              <td>{{ abs.usuario }}</td>
              <td>{{ abs.fecha | fecha }}</td>
              <td>
                <button class="btn btn-danger btn-sm" @click="eliminarAbstencion(abs)">Eliminar</button>
              </td>
            </tr>
            <tr v-if="abstenciones.length === 0">
              <td colspan="7" class="text-center">No hay abstenciones registradas.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="mensaje" class="alert mt-3" :class="{'alert-success': status==='success', 'alert-danger': status==='error'}">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'FuncionAbstencionPage',
  data() {
    return {
      filtro: {
        cvecuenta: ''
      },
      abstenciones: [],
      form: {
        cvecuenta: '',
        anio: '',
        bimestre: '',
        observacion: ''
      },
      mensaje: '',
      status: ''
    }
  },
  filters: {
    fecha(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    }
  },
  methods: {
    async buscarAbstenciones() {
      this.mensaje = '';
      this.status = '';
      let params = { action: 'get_abstencion_by_cuenta', params: { cvecuenta: this.filtro.cvecuenta } };
      try {
        let res = await this.$axios.post('/api/execute', params);
        if (res.data.status === 'success') {
          this.abstenciones = res.data.data;
        } else {
          this.mensaje = res.data.message;
          this.status = 'error';
        }
      } catch (e) {
        this.mensaje = e.message;
        this.status = 'error';
      }
    },
    async agregarAbstencion() {
      this.mensaje = '';
      this.status = '';
      let params = {
        action: 'add_abstencion',
        params: {
          cvecuenta: this.form.cvecuenta,
          anio: this.form.anio,
          bimestre: this.form.bimestre,
          observacion: this.form.observacion,
          usuario: this.$store.state.usuario || 'sistema'
        }
      };
      try {
        let res = await this.$axios.post('/api/execute', params);
        if (res.data.status === 'success') {
          this.mensaje = res.data.message;
          this.status = 'success';
          this.buscarAbstenciones();
        } else {
          this.mensaje = res.data.message;
          this.status = 'error';
        }
      } catch (e) {
        this.mensaje = e.message;
        this.status = 'error';
      }
    },
    async eliminarAbstencion(abs) {
      if (!confirm('¿Está seguro de eliminar esta abstención?')) return;
      this.mensaje = '';
      this.status = '';
      let params = {
        action: 'remove_abstencion',
        params: {
          cvecuenta: abs.cvecuenta,
          anio: abs.anio,
          bimestre: abs.bimestre,
          usuario: this.$store.state.usuario || 'sistema'
        }
      };
      try {
        let res = await this.$axios.post('/api/execute', params);
        if (res.data.status === 'success') {
          this.mensaje = res.data.message;
          this.status = 'success';
          this.buscarAbstenciones();
        } else {
          this.mensaje = res.data.message;
          this.status = 'error';
        }
      } catch (e) {
        this.mensaje = e.message;
        this.status = 'error';
      }
    }
  },
  mounted() {
    // Carga inicial de todas las abstenciones
    this.$axios.post('/api/execute', { action: 'get_abstenciones' })
      .then(res => {
        if (res.data.status === 'success') {
          this.abstenciones = res.data.data;
        }
      });
  }
}
</script>

<style scoped>
.container {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  margin-bottom: 1rem;
}
</style>

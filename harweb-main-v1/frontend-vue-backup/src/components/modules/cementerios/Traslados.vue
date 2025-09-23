<template>
  <div class="traslados-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Traslados de Pagos</li>
      </ol>
    </nav>
    <h2>Traslado de Pagos de Cementerio</h2>
    <form @submit.prevent="verificarOrigen">
      <fieldset>
        <legend>Trasladar De (Origen)</legend>
        <div class="row">
          <div class="col-md-3">
            <label>Cementerio</label>
            <select v-model="origen.cementerio" class="form-control" required>
              <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                {{ cem.nombre }}
              </option>
            </select>
          </div>
          <div class="col-md-2">
            <label>Clase</label>
            <input type="number" v-model.number="origen.clase" class="form-control" min="1" max="3" required />
          </div>
          <div class="col-md-2">
            <label>Clase Alfa</label>
            <input type="text" v-model="origen.clase_alfa" class="form-control" maxlength="10" />
          </div>
          <div class="col-md-2">
            <label>Sección</label>
            <input type="number" v-model.number="origen.seccion" class="form-control" min="1" required />
          </div>
          <div class="col-md-2">
            <label>Sección Alfa</label>
            <input type="text" v-model="origen.seccion_alfa" class="form-control" maxlength="10" />
          </div>
        </div>
        <div class="row mt-2">
          <div class="col-md-2">
            <label>Línea</label>
            <input type="number" v-model.number="origen.linea" class="form-control" min="1" required />
          </div>
          <div class="col-md-2">
            <label>Línea Alfa</label>
            <input type="text" v-model="origen.linea_alfa" class="form-control" maxlength="20" />
          </div>
          <div class="col-md-2">
            <label>Fosa</label>
            <input type="number" v-model.number="origen.fosa" class="form-control" min="1" required />
          </div>
          <div class="col-md-2">
            <label>Fosa Alfa</label>
            <input type="text" v-model="origen.fosa_alfa" class="form-control" maxlength="20" />
          </div>
          <div class="col-md-2 align-self-end">
            <button type="submit" class="btn btn-primary">Verificar Origen</button>
          </div>
        </div>
      </fieldset>
    </form>
    <div v-if="pagosOrigen.length">
      <h5 class="mt-4">Pagos encontrados en Origen</h5>
      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Fecha</th>
            <th>Importe</th>
            <th>Vigencia</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in pagosOrigen" :key="p.control_id">
            <td>{{ p.control_id }}</td>
            <td>{{ p.fecing }}</td>
            <td>{{ p.importe_anual }}</td>
            <td>{{ p.vigencia }}</td>
            <td>{{ p.usuario }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <form v-if="pagosOrigen.length" @submit.prevent="verificarDestino">
      <fieldset class="mt-4">
        <legend>Trasladar A (Destino)</legend>
        <div class="row">
          <div class="col-md-3">
            <label>Cementerio</label>
            <select v-model="destino.cementerio" class="form-control" required>
              <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                {{ cem.nombre }}
              </option>
            </select>
          </div>
          <div class="col-md-2">
            <label>Clase</label>
            <input type="number" v-model.number="destino.clase" class="form-control" min="1" max="3" required />
          </div>
          <div class="col-md-2">
            <label>Clase Alfa</label>
            <input type="text" v-model="destino.clase_alfa" class="form-control" maxlength="10" />
          </div>
          <div class="col-md-2">
            <label>Sección</label>
            <input type="number" v-model.number="destino.seccion" class="form-control" min="1" required />
          </div>
          <div class="col-md-2">
            <label>Sección Alfa</label>
            <input type="text" v-model="destino.seccion_alfa" class="form-control" maxlength="10" />
          </div>
        </div>
        <div class="row mt-2">
          <div class="col-md-2">
            <label>Línea</label>
            <input type="number" v-model.number="destino.linea" class="form-control" min="1" required />
          </div>
          <div class="col-md-2">
            <label>Línea Alfa</label>
            <input type="text" v-model="destino.linea_alfa" class="form-control" maxlength="20" />
          </div>
          <div class="col-md-2">
            <label>Fosa</label>
            <input type="number" v-model.number="destino.fosa" class="form-control" min="1" required />
          </div>
          <div class="col-md-2">
            <label>Fosa Alfa</label>
            <input type="text" v-model="destino.fosa_alfa" class="form-control" maxlength="20" />
          </div>
          <div class="col-md-2 align-self-end">
            <button type="submit" class="btn btn-primary">Verificar Destino</button>
          </div>
        </div>
      </fieldset>
    </form>
    <div v-if="pagosDestino.length">
      <h5 class="mt-4">Pagos encontrados en Destino</h5>
      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Fecha</th>
            <th>Importe</th>
            <th>Vigencia</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in pagosDestino" :key="p.control_id">
            <td>{{ p.control_id }}</td>
            <td>{{ p.fecing }}</td>
            <td>{{ p.importe_anual }}</td>
            <td>{{ p.vigencia }}</td>
            <td>{{ p.usuario }}</td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-success" @click="trasladarPagos">Trasladar Pagos</button>
    </div>
    <div v-if="mensaje" class="alert mt-3" :class="{'alert-success': exito, 'alert-danger': !exito}">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'TrasladosPage',
  data() {
    return {
      cementerios: [],
      origen: {
        cementerio: '', clase: 1, clase_alfa: '', seccion: 1, seccion_alfa: '', linea: 1, linea_alfa: '', fosa: 1, fosa_alfa: ''
      },
      destino: {
        cementerio: '', clase: 1, clase_alfa: '', seccion: 1, seccion_alfa: '', linea: 1, linea_alfa: '', fosa: 1, fosa_alfa: ''
      },
      pagosOrigen: [],
      pagosDestino: [],
      mensaje: '',
      exito: false
    }
  },
  created() {
    this.cargarCementerios();
  },
  methods: {
    async cargarCementerios() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'cementerios.listarCementerios',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.cementerios = res.data.data;
          if (this.cementerios.length) {
            this.origen.cementerio = this.cementerios[0].cementerio;
            this.destino.cementerio = this.cementerios[0].cementerio;
          }
        } else {
          throw new Error(res.data.message || 'Error en la solicitud');
        }
      } catch (error) {
        console.error('Error cargando cementerios:', error.response?.data?.message || error.message || 'Error de conexión');
      }
    },
    async verificarOrigen() {
      this.mensaje = '';
      this.pagosOrigen = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'cementerios.buscarPagosOrigen',
          payload: this.origen
        });
        if (res.data.status === 'success' && res.data.data.length) {
          this.pagosOrigen = res.data.data;
          this.mensaje = '';
        } else {
          this.mensaje = 'No se encontraron pagos en el registro de origen.';
          this.exito = false;
        }
      } catch (error) {
        this.mensaje = error.response?.data?.message || error.message || 'Error de conexión';
        this.exito = false;
      }
    },
    async verificarDestino() {
      this.mensaje = '';
      this.pagosDestino = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'cementerios.buscarPagosDestino',
          payload: this.destino
        });
        if (res.data.status === 'success' && res.data.data.length) {
          this.pagosDestino = res.data.data;
          this.mensaje = '';
        } else {
          this.mensaje = 'No se encontraron datos en el registro destino.';
          this.exito = false;
        }
      } catch (error) {
        this.mensaje = error.response?.data?.message || error.message || 'Error de conexión';
        this.exito = false;
      }
    },
    async trasladarPagos() {
      if (!this.pagosOrigen.length || !this.pagosDestino.length) {
        this.mensaje = 'Debe verificar origen y destino antes de trasladar.';
        this.exito = false;
        return;
      }
      const payload = {
        origen_control_id: this.pagosOrigen[0].control_id,
        destino_cementerio: this.destino.cementerio,
        destino_clase: this.destino.clase,
        destino_clase_alfa: this.destino.clase_alfa,
        destino_seccion: this.destino.seccion,
        destino_seccion_alfa: this.destino.seccion_alfa,
        destino_linea: this.destino.linea,
        destino_linea_alfa: this.destino.linea_alfa,
        destino_fosa: this.destino.fosa,
        destino_fosa_alfa: this.destino.fosa_alfa,
        destino_control_rcm: this.pagosDestino[0].control_rcm
      };
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'cementerios.trasladarPagos',
          payload
        });
        if (res.data.status === 'success') {
          this.mensaje = 'El registro se ha trasladado correctamente.';
          this.exito = true;
          this.pagosOrigen = [];
          this.pagosDestino = [];
        } else {
          throw new Error(res.data.message || 'Error al trasladar pagos.');
        }
      } catch (error) {
        this.mensaje = error.response?.data?.message || error.message || 'Error de conexión';
        this.exito = false;
      }
    }
  }
}
</script>

<style scoped>
.traslados-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  background: transparent;
  padding: 0;
  margin-bottom: 1rem;
}
</style>

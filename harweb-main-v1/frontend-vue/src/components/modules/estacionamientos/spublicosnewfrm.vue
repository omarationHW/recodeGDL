<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Alta de Estacionamiento Público</li>
      </ol>
    </nav>
    <h2>Alta de Estacionamiento Público</h2>
    <form @submit.prevent="onSubmit">
      <div class="row">
        <div class="col-md-4 mb-3">
          <label for="rfc">RFC</label>
          <div class="input-group">
            <input v-model="form.rfc" id="rfc" class="form-control" maxlength="13" @input="onRfcInput" />
            <button class="btn btn-secondary" type="button" @click="buscarPersonaRfc">Buscar</button>
          </div>
        </div>
        <div class="col-md-8 mb-3">
          <label>Nombre</label>
          <input v-model="form.nombre" class="form-control" readonly />
        </div>
      </div>
      <div v-if="personasRfc.length > 0" class="mb-3">
        <div class="alert alert-info">Seleccione el propietario correcto:</div>
        <table class="table table-sm table-bordered">
          <thead>
            <tr>
              <th>No. Municipio</th>
              <th>RFC</th>
              <th>Nombre</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in personasRfc" :key="p.id_esta_persona">
              <td>{{ p.id_esta_persona }}</td>
              <td>{{ p.rfc }}</td>
              <td>{{ p.nombre }}</td>
              <td><button class="btn btn-primary btn-sm" @click="seleccionarPersona(p)"><i class="fa fa-check"></i> Seleccionar</button></td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="row">
        <div class="col-md-4 mb-3">
          <label for="cvepredial">Clave Predial</label>
          <div class="input-group">
            <input v-model="form.cvepredial" id="cvepredial" class="form-control" maxlength="11" />
            <button class="btn btn-secondary" type="button" @click="buscarPredio">Buscar</button>
            <button class="btn btn-outline-info" type="button" @click="abrirMapa" v-if="predio.cvecatastral"><i class="fa fa-map"></i> Mapa</button>
          </div>
        </div>
        <div class="col-md-8 mb-3">
          <label>Datos del Predio</label>
          <div class="card card-body">
            <div class="row">
              <div class="col-md-4"><strong>Cve Catastral:</strong> {{ predio.cvecatastral }}</div>
              <div class="col-md-4"><strong>Cuenta:</strong> {{ predio.cuenta }}</div>
              <div class="col-md-4"><strong>Sector:</strong> {{ predio.sector_nombre }}</div>
            </div>
            <div class="row mt-2">
              <div class="col-md-6"><strong>Calle:</strong> <input v-model="form.calle" class="form-control form-control-sm" /></div>
              <div class="col-md-3"><strong>Exterior:</strong> <input v-model="form.numext" class="form-control form-control-sm" /></div>
              <div class="col-md-3"><strong>Zona:</strong> {{ predio.zona }} / <strong>Subzona:</strong> {{ predio.subzona }}</div>
            </div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-md-3 mb-3">
          <label for="numesta">No. Estacionamiento</label>
          <input v-model.number="form.numesta" id="numesta" type="number" min="1" class="form-control" />
          <small class="text-muted">Último: {{ ultimoNumEsta }}</small>
        </div>
        <div class="col-md-3 mb-3">
          <label for="categoria">Categoría</label>
          <select v-model="form.pubcategoria_id" id="categoria" class="form-select">
            <option v-for="cat in categorias" :key="cat.id" :value="cat.id">{{ cat.descripcion }}</option>
          </select>
        </div>
        <div class="col-md-2 mb-3">
          <label for="cajones">Cajones</label>
          <input v-model.number="form.cupo" id="cajones" type="number" min="1" class="form-control" />
        </div>
        <div class="col-md-2 mb-3">
          <label for="telefono">Teléfono</label>
          <input v-model="form.telefono" id="telefono" maxlength="10" class="form-control" />
        </div>
        <div class="col-md-2 mb-3">
          <label for="licencia">Licencia</label>
          <input v-model.number="form.numlicencia" id="licencia" type="number" min="0" class="form-control" />
        </div>
      </div>
      <div class="row">
        <div class="col-md-2 mb-3">
          <label for="fecha_inicial">Fecha Inicial</label>
          <input v-model="form.fecha_inicial" id="fecha_inicial" type="date" class="form-control" />
        </div>
        <div class="col-md-2 mb-3">
          <label for="fecha_at">Inicia Actividad</label>
          <input v-model="form.fecha_at" id="fecha_at" type="date" class="form-control" />
        </div>
        <div class="col-md-2 mb-3">
          <label for="fecha_vencimiento">Vencimiento</label>
          <input v-model="form.fecha_vencimiento" id="fecha_vencimiento" type="date" class="form-control" />
        </div>
        <div class="col-md-2 mb-3">
          <label for="solicitud">Solicitud</label>
          <input v-model.number="form.solicitud" id="solicitud" type="number" min="0" class="form-control" />
        </div>
        <div class="col-md-2 mb-3">
          <label for="control">Control</label>
          <input v-model.number="form.control" id="control" type="number" min="0" class="form-control" />
        </div>
      </div>
      <div class="mb-3">
        <button class="btn btn-success" type="submit">Dar de Alta</button>
      </div>
      <div v-if="mensaje" class="alert" :class="{'alert-success': exito, 'alert-danger': !exito}">{{ mensaje }}</div>
    </form>
    <div v-if="showMapa" class="modal fade show d-block" tabindex="-1" style="background:rgba(0,0,0,0.5)">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Mapa del Predio</h5>
            <button type="button" class="btn-close" @click="showMapa=false"></button>
          </div>
          <div class="modal-body">
            <iframe :src="mapaUrl" width="100%" height="400" frameborder="0"></iframe>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AltaEstacionamientoPublico',
  data() {
    return {
      form: {
        rfc: '',
        nombre: '',
        cvepredial: '',
        calle: '',
        numext: '',
        telefono: '',
        pubcategoria_id: '',
        cupo: 0,
        numesta: 1,
        numlicencia: 0,
        fecha_inicial: '',
        fecha_at: '',
        fecha_vencimiento: '',
        solicitud: 0,
        control: 0
      },
      personasRfc: [],
      categorias: [],
      predio: {},
      ultimoNumEsta: 1,
      mensaje: '',
      exito: false,
      showMapa: false,
      mapaUrl: ''
    }
  },
  mounted() {
    this.cargarCategorias();
    this.cargarUltimoNumEsta();
  },
  methods: {
    onRfcInput() {
      this.personasRfc = [];
      this.form.nombre = '';
    },
    buscarPersonaRfc() {
      if (this.form.rfc.length < 4) {
        this.mensaje = 'Ingrese al menos 4 caracteres para buscar RFC';
        this.exito = false;
        return;
      }
      this.$axios.post('/api/execute', {
        action: 'buscar_persona_rfc',
        params: { rfc: this.form.rfc }
      }).then(resp => {
        if (resp.data.success) {
          this.personasRfc = resp.data.data;
          if (this.personasRfc.length === 1) {
            this.seleccionarPersona(this.personasRfc[0]);
          }
        }
      });
    },
    seleccionarPersona(p) {
      this.form.rfc = p.rfc;
      this.form.nombre = p.nombre;
      this.personasRfc = [];
    },
    cargarCategorias() {
      this.$axios.post('/api/execute', {
        action: 'listar_categorias',
        params: {}
      }).then(resp => {
        if (resp.data.success) {
          this.categorias = resp.data.data;
        }
      });
    },
    cargarUltimoNumEsta() {
      this.$axios.post('/api/execute', {
        action: 'ultimo_num_estacionamiento',
        params: {}
      }).then(resp => {
        if (resp.data.success) {
          this.ultimoNumEsta = (resp.data.data.numesta || 0) + 1;
          this.form.numesta = this.ultimoNumEsta;
        }
      });
    },
    buscarPredio() {
      if (!this.form.cvepredial) {
        this.mensaje = 'Ingrese la clave predial';
        this.exito = false;
        return;
      }
      this.$axios.post('/api/execute', {
        action: 'consultar_predio',
        params: { dato: this.form.cvepredial }
      }).then(resp => {
        if (resp.data.success && resp.data.data) {
          this.predio = resp.data.data;
          this.form.calle = this.predio.calle;
          this.form.numext = this.predio.numext;
        } else {
          this.mensaje = 'Cuenta Predial Incorrecta o Cancelada';
          this.exito = false;
        }
      });
    },
    abrirMapa() {
      if (this.predio.cvecatastral) {
        this.mapaUrl = `http://192.168.4.20:8080/Visor/index.html#user=123&session=se123&clavePredi0=${this.predio.cvecatastral}`;
        this.showMapa = true;
      }
    },
    async onSubmit() {
      this.mensaje = '';
      // Validaciones
      if (!this.form.rfc) {
        this.mensaje = 'Debe seleccionar un propietario válido';
        this.exito = false;
        return;
      }
      if (!this.predio || !this.predio.cvecuenta) {
        this.mensaje = 'No tiene la cuenta predial asignada correctamente, verifique';
        this.exito = false;
        return;
      }
      if (!this.form.pubcategoria_id) {
        this.mensaje = 'Debe seleccionar una categoría';
        this.exito = false;
        return;
      }
      if (!this.form.cupo || this.form.cupo < 1) {
        this.mensaje = 'Debe indicar el número de cajones';
        this.exito = false;
        return;
      }
      // Fechas
      if (!this.form.fecha_inicial) this.form.fecha_inicial = new Date().toISOString().substr(0,10);
      if (!this.form.fecha_at) this.form.fecha_at = new Date().toISOString().substr(0,10);
      if (!this.form.fecha_vencimiento) {
        let d = new Date();
        d.setMonth(11); d.setDate(31);
        this.form.fecha_vencimiento = d.toISOString().substr(0,10);
      }
      // Costo forma
      let costoForma = 0;
      await this.$axios.post('/api/execute', { action: 'costo_forma', params: {} }).then(resp => {
        if (resp.data.success && resp.data.data) {
          costoForma = resp.data.data.costo_forma;
        }
      });
      // Alta estacionamiento
      let altaParams = {
        pubcategoria_id: this.form.pubcategoria_id,
        numesta: this.form.numesta,
        sector: this.obtenerSector(this.predio.recaud),
        zona: this.predio.zona,
        subzona: this.predio.subzona,
        numlicencia: this.form.numlicencia || 0,
        axolicencias: 0,
        cvecuenta: this.predio.cvecuenta,
        nombre: this.form.nombre,
        calle: this.form.calle,
        numext: this.form.numext,
        telefono: this.form.telefono,
        cupo: this.form.cupo,
        fecha_at: this.form.fecha_at,
        fecha_inicial: this.form.fecha_inicial,
        fecha_vencimiento: this.form.fecha_vencimiento,
        rfc: this.form.rfc,
        solicitud: this.form.solicitud || 0,
        control: this.form.control || 0,
        movtos_no: 1,
        movto_cve: 'V',
        movto_usr: 1 // TODO: obtener usuario real
      };
      let altaResp = await this.$axios.post('/api/execute', {
        action: 'alta_estacionamiento',
        params: altaParams
      });
      if (altaResp.data.success && altaResp.data.data && altaResp.data.data.idnvo > 0) {
        // Alta adeudo forma
        let adeudoParams = {
          pubmain_id: altaResp.data.data.idnvo,
          axo: this.form.fecha_inicial.substr(0,4),
          mes: this.form.fecha_inicial.substr(5,2),
          concepto: `Solicitud : ${this.form.solicitud}`,
          ade_importe: costoForma,
          id_usuario: 1 // TODO: usuario real
        };
        await this.$axios.post('/api/execute', {
          action: 'alta_adeudo_forma',
          params: adeudoParams
        });
        this.mensaje = altaResp.data.data.resultstr;
        this.exito = true;
        this.cargarUltimoNumEsta();
      } else {
        this.mensaje = altaResp.data.data ? altaResp.data.data.resultstr : 'Error en el alta';
        this.exito = false;
      }
    },
    obtenerSector(recaud) {
      switch (recaud) {
        case 1: return 'J';
        case 2: return 'R';
        case 3: return 'L';
        case 4: return 'H';
        default: return '';
      }
    }
  }
}
</script>

<style scoped>
.modal.fade.show {
  display: block;
}
</style>

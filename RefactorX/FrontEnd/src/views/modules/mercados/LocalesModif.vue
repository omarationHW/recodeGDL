<template>
  <div class="module-view">
    <h1>Modificación de Locales</h1>
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Modificación de Locales</span>
    </nav>
    <form @submit.prevent="onBuscar">
      <fieldset>
        <legend>Búsqueda de Local</legend>
        <div class="form-row">
          <label>Recaudadora:</label>
          <select v-model="form.oficina" required>
            <option v-for="z in catalogos.recaudadoras" :key="z.id_rec" :value="z.id_rec">{{z.id_rec}} - {{z.recaudadora}}</option>
          </select>
          <label>Mercado:</label>
          <input v-model="form.num_mercado" type="number" required maxlength="3" />
          <label>Categoria:</label>
          <input v-model="form.categoria" type="number" required maxlength="1" />
          <label>Sección:</label>
          <select v-model="form.seccion" required>
            <option v-for="s in catalogos.secciones" :key="s.seccion" :value="s.seccion">{{s.seccion}}</option>
          </select>
          <label>Local:</label>
          <input v-model="form.local" type="number" required maxlength="7" />
          <label>Letra:</label>
          <input v-model="form.letra_local" maxlength="1" />
          <label>Bloque:</label>
          <input v-model="form.bloque" maxlength="1" />
        </div>
        <button type="submit">Buscar</button>
      </fieldset>
    </form>
    <div v-if="local">
      <form @submit.prevent="onModificar">
        <fieldset>
          <legend>Datos del Local</legend>
          <div class="form-row">
            <label>Nombre:</label>
            <input v-model="local.nombre" required maxlength="60" />
            <label>Domicilio:</label>
            <input v-model="local.domicilio" maxlength="40" />
            <label>Sector:</label>
            <select v-model="local.sector" required>
              <option v-for="s in catalogos.sectores" :key="s.clave" :value="s.clave">{{s.descripcion}}</option>
            </select>
            <label>Zona:</label>
            <select v-model="local.zona" required>
              <option v-for="z in catalogos.zonas" :key="z.id_zona" :value="z.id_zona">{{z.id_zona}} - {{z.zona}}</option>
            </select>
            <label>Descripción:</label>
            <input v-model="local.descripcion_local" maxlength="20" />
            <label>Superficie:</label>
            <input v-model.number="local.superficie" type="number" step="0.01" required />
            <label>Giro:</label>
            <input v-model.number="local.giro" type="number" required />
            <label>Fecha Alta:</label>
            <input v-model="local.fecha_alta" type="date" required />
            <label>Fecha Baja:</label>
            <input v-model="local.fecha_baja" type="date" />
            <label>Vigencia:</label>
            <select v-model="local.vigencia" required>
              <option value="A">VIGENTE</option>
              <option value="B">BAJA</option>
              <option value="C">BAJA POR ACUERDO</option>
              <option value="D">BAJA ADMINISTRATIVA</option>
            </select>
            <label>Clave Cuota:</label>
            <select v-model="local.clave_cuota" required>
              <option v-for="c in catalogos.cuotas" :key="c.clave_cuota" :value="c.clave_cuota">{{c.clave_cuota}} - {{c.descripcion}}</option>
            </select>
            <label>Movimiento:</label>
            <select v-model="local.tipo_movimiento" required>
              <option v-for="m in catalogos.movimientos" :key="m.clave_movimiento" :value="m.clave_movimiento">{{m.clave_movimiento}} - {{m.descripcion}}</option>
            </select>
            <label>Bloqueo:</label>
            <select v-model="local.bloqueo">
              <option value="0">Sin bloqueo</option>
              <option v-for="b in catalogos.bloqueos" :key="b.cve_bloqueo" :value="b.cve_bloqueo">{{b.cve_bloqueo}} - {{b.descripcion}}</option>
            </select>
            <label v-if="local.tipo_movimiento==12 || local.tipo_movimiento==13">Clave Bloqueo:</label>
            <select v-if="local.tipo_movimiento==12 || local.tipo_movimiento==13" v-model="local.cve_bloqueo">
              <option v-for="b in catalogos.bloqueos" :key="b.cve_bloqueo" :value="b.cve_bloqueo">{{b.cve_bloqueo}} - {{b.descripcion}}</option>
            </select>
            <label v-if="local.tipo_movimiento==12">Fecha Inicio Bloqueo:</label>
            <input v-if="local.tipo_movimiento==12" v-model="local.fecha_inicio_bloqueo" type="date" />
            <label v-if="local.tipo_movimiento==13">Fecha Final Bloqueo:</label>
            <input v-if="local.tipo_movimiento==13" v-model="local.fecha_final_bloqueo" type="date" />
            <label v-if="local.tipo_movimiento==12 || local.tipo_movimiento==13">Observación:</label>
            <input v-if="local.tipo_movimiento==12 || local.tipo_movimiento==13" v-model="local.observacion" maxlength="250" />
          </div>
          <button type="submit">Modificar</button>
        </fieldset>
      </form>
    </div>
    <div v-if="message" :class="{'success': success, 'error': !success}">{{message}}</div>
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'LocalesModifPage',
  data() {
    return {
      form: {
        oficina: '',
        num_mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: ''
      },
      local: null,
      catalogos: {
        zonas: [],
        cuotas: [],
        sectores: [],
        movimientos: [],
        bloqueos: [],
        recaudadoras: [],
        secciones: []
      },
      message: '',
      success: false
    }
  },
  created() {
    this.loadCatalogos();
  },
  methods: {
    async loadCatalogos() {
      // Cargar catálogos
      const [cat, mov, blq] = await Promise.all([
        fetch('/api/execute', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({action: 'catalogos'})
        }).then(r=>r.json()),
        fetch('/api/execute', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({action: 'movimientos'})
        }).then(r=>r.json()),
        fetch('/api/execute', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({action: 'bloqueos'})
        }).then(r=>r.json())
      ]);
      this.catalogos.zonas = cat.data.zonas;
      this.catalogos.cuotas = cat.data.cuotas;
      this.catalogos.sectores = cat.data.sectores;
      this.catalogos.recaudadoras = cat.data.recaudadoras || [];
      this.catalogos.secciones = cat.data.secciones || [];
      this.catalogos.movimientos = mov.data;
      this.catalogos.bloqueos = blq.data;
    },
    async onBuscar() {
      this.message = '';
      this.success = false;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({action: 'buscar_local', params: this.form})
      }).then(r=>r.json());
      if (res.success) {
        this.local = res.data;
        this.success = true;
        this.message = 'Local encontrado';
      } else {
        this.local = null;
        this.success = false;
        this.message = res.message;
      }
    },
    async onModificar() {
      this.message = '';
      this.success = false;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({action: 'modificar_local', params: this.local})
      }).then(r=>r.json());
      if (res.success) {
        this.success = true;
        this.message = 'Local modificado correctamente';
      } else {
        this.success = false;
        this.message = res.message;
      }
    }
  }
}
</script>

<style scoped>
.locales-modif-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
fieldset {
  margin-bottom: 1.5rem;
  border: 1px solid #ccc;
  padding: 1rem;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
}
.form-row label {
  min-width: 100px;
  font-weight: bold;
}
.form-row input, .form-row select {
  min-width: 120px;
}
.success {
  color: green;
  font-weight: bold;
}
.error {
  color: red;
  font-weight: bold;
}
</style>

<template>
  <div class="rbaja-page">
    <h1>Baja de Local/Concesión</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Baja de Local</li>
      </ol>
    </nav>
    <form @submit.prevent="buscarLocal">
      <fieldset>
        <legend>Control del local</legend>
        <div class="form-row">
          <div class="form-group col-md-2">
            <label for="numero">Número</label>
            <input v-model="form.numero" id="numero" maxlength="3" class="form-control" required @keypress="soloNumeros($event, 3)" />
          </div>
          <div class="form-group col-md-2">
            <label for="letra">Letra</label>
            <input v-model="form.letra" id="letra" maxlength="1" class="form-control" style="text-transform:uppercase" />
          </div>
          <div class="form-group col-md-2 align-self-end">
            <button type="submit" class="btn btn-primary">Buscar</button>
          </div>
        </div>
      </fieldset>
    </form>
    <div v-if="local">
      <hr />
      <h4>Datos del Local</h4>
      <div class="row">
        <div class="col-md-6">
          <dl class="row">
            <dt class="col-sm-4">Concesionario</dt>
            <dd class="col-sm-8">{{ local.concesionario }}</dd>
            <dt class="col-sm-4">Ubicación</dt>
            <dd class="col-sm-8">{{ local.ubicacion }}</dd>
            <dt class="col-sm-4">Superficie</dt>
            <dd class="col-sm-8">{{ local.superficie }}</dd>
            <dt class="col-sm-4">Licencia</dt>
            <dd class="col-sm-8">{{ local.licencia }}</dd>
            <dt class="col-sm-4">Tipo de Local</dt>
            <dd class="col-sm-8">{{ local.descrip_unidad }}</dd>
            <dt class="col-sm-4">Inicio Obligación</dt>
            <dd class="col-sm-8">{{ local.fecha_inicio }}</dd>
            <dt class="col-sm-4">Recaudadora</dt>
            <dd class="col-sm-8">{{ local.id_recaudadora }}</dd>
            <dt class="col-sm-4">Sector</dt>
            <dd class="col-sm-8">{{ local.sector }}</dd>
            <dt class="col-sm-4">Zona</dt>
            <dd class="col-sm-8">{{ local.id_zona }}</dd>
            <dt class="col-sm-4">Estado</dt>
            <dd class="col-sm-8">{{ local.descrip_stat }}</dd>
          </dl>
        </div>
      </div>
      <div v-if="local.cve_stat !== 'V'" class="alert alert-warning">
        LOCAL EN SUSPENSIÓN O CANCELADO, intentalo de nuevo
      </div>
      <div v-else>
        <form @submit.prevent="aplicarBaja">
          <fieldset>
            <legend>Periodo de Término de Obligación</legend>
            <div class="form-row">
              <div class="form-group col-md-3">
                <label for="aso">Año</label>
                <input v-model="form.aso" id="aso" maxlength="4" class="form-control" required @keypress="soloNumeros($event, 4)" />
              </div>
              <div class="form-group col-md-3">
                <label for="mes">Mes</label>
                <select v-model="form.mes" id="mes" class="form-control">
                  <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
                </select>
              </div>
              <div class="form-group col-md-3 align-self-end">
                <button type="submit" class="btn btn-danger">Aplicar Baja</button>
              </div>
            </div>
          </fieldset>
        </form>
      </div>
    </div>
    <div v-if="mensaje" class="alert" :class="{'alert-success': exito, 'alert-danger': !exito}">
      {{ mensaje }}
    </div>
    <button class="btn btn-secondary mt-3" @click="$router.push('/')">Salir</button>
  </div>
</template>

<script>
export default {
  name: 'RBajaPage',
  data() {
    return {
      form: {
        numero: '',
        letra: '',
        aso: '',
        mes: '01'
      },
      meses: ['01','02','03','04','05','06','07','08','09','10','11','12'],
      local: null,
      mensaje: '',
      exito: false
    };
  },
  methods: {
    soloNumeros(evt, maxlen) {
      const charCode = evt.which ? evt.which : evt.keyCode;
      if (charCode < 48 || charCode > 57 || evt.target.value.length >= maxlen) {
        evt.preventDefault();
      }
    },
    async buscarLocal() {
      this.mensaje = '';
      this.local = null;
      if (!this.form.numero) {
        this.mensaje = 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo';
        this.exito = false;
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'rbaja.buscar_local',
          params: {
            numero: this.form.numero,
            letra: this.form.letra
          }
        });
        if (res.data.success && res.data.data.length > 0) {
          this.local = res.data.data[0];
        } else {
          this.mensaje = 'No existe LOCAL con este dato, intentalo de nuevo';
          this.exito = false;
        }
      } catch (e) {
        this.mensaje = 'Error al buscar local: ' + (e.response?.data?.message || e.message);
        this.exito = false;
      }
    },
    async aplicarBaja() {
      this.mensaje = '';
      if (!this.form.aso || this.form.aso === '0') {
        this.mensaje = 'Falta el dato del AÑO, intentalo de nuevo';
        this.exito = false;
        return;
      }
      // Verificar adeudos pasados
      try {
        const periodo = `${this.form.aso}-${this.form.mes}`;
        const resPas = await this.$axios.post('/api/execute', {
          action: 'rbaja.verificar_adeudos',
          params: {
            id_34_datos: this.local.id_34_datos,
            periodo
          }
        });
        const resPost = await this.$axios.post('/api/execute', {
          action: 'rbaja.verificar_adeudos_post',
          params: {
            id_34_datos: this.local.id_34_datos,
            periodo
          }
        });
        if ((resPas.data.data && resPas.data.data.length === 0) && (resPost.data.data && resPost.data.data.length === 0)) {
          if (confirm('¿Deseas darlo de BAJA?')) {
            // Ejecutar baja
            const resBaja = await this.$axios.post('/api/execute', {
              action: 'rbaja.cancelar_local',
              params: {
                id_34_datos: this.local.id_34_datos,
                axo_fin: parseInt(this.form.aso),
                mes_fin: parseInt(this.form.mes)
              }
            });
            if (resBaja.data.data && resBaja.data.data[0].codigo === 0) {
              this.mensaje = 'Se ejecutó correctamente la Cancelación del Local/Concesión';
              this.exito = true;
              this.local = null;
            } else {
              this.mensaje = resBaja.data.data[0]?.mensaje || 'Error al cancelar Local/Concesión';
              this.exito = false;
            }
          } else {
            this.mensaje = 'TU RESPUESTA FUE NO, intentalo de nuevo';
            this.exito = false;
          }
        } else {
          this.mensaje = 'NO ES POSIBLE DARLO DE BAJA PUES TIENE ADEUDOS VIGENTES O POSTERIORES CON OTRO STATUS, intentalo de nuevo';
          this.exito = false;
        }
      } catch (e) {
        this.mensaje = 'Error al aplicar baja: ' + (e.response?.data?.message || e.message);
        this.exito = false;
      }
    }
  }
};
</script>

<style scoped>
.rbaja-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
